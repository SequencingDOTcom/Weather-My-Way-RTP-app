using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using log4net;
using Mandrill;
using Mandrill.Models;
using Mandrill.Requests.Messages;
using Sequencing.WeatherApp.Controllers.WeatherUnderground;
using Twilio;

namespace Sequencing.WeatherApp.Controllers
{
    /// <summary>
    /// User notifications implementation sender: emails/sms/on site notification
    /// </summary>
    public class EmailWorker
    {
        private const string MANDRILL_TEMPLATE = "weather-my-way-notification";

        public bool GetEmailSend(string userName)
        {
            using (var _ctx = new WeatherAppDbEntities())
            {
                var _val = _ctx.SendInfoes.FirstOrDefault(info => info.UserName == userName);
                if (_val == null)
                    return false;
                return _val.SendEmail ?? false;
            }
        }

        public const string MELANOMA_APP_CHAIN_ID = "Chain9";
        public const string VITD_APP_CHAIN_ID = "Chain88";

        private Tuple<long, long> GetJobId(SendInfo info)
        {
            var _srv = new BackendServiceFacade(Options.ApiUrl, info.UserName);
            var _rs = _srv.StartApp(MELANOMA_APP_CHAIN_ID, new Dictionary<string, string> { { "dataSourceId", info.DataFileId } });
            var _rs2 = _srv.StartApp(VITD_APP_CHAIN_ID, new Dictionary<string, string> { { "dataSourceId", info.DataFileId } });

            while (true)
            {
                var _appStatus = _srv.CheckAppStatus(Convert.ToInt64(_rs.jobId));
                var _appStatus2 = _srv.CheckAppStatus(Convert.ToInt64(_rs2.jobId));
                if (_appStatus == "Completed" && _appStatus2 == "Completed")
                    break;
                Thread.Sleep(5000);
            }

            return Tuple.Create(_rs.jobId, _rs2.jobId);
        }

        private string SmsSendImpl(string from, string phone, string msg)
        {
            var twilio = new TwilioRestClient(Options.TwilioAccountSid, Options.TwilioAuthToken);
            var _logger = LogManager.GetLogger(GetType());


            var _sendMessage = twilio.SendMessage(from, phone, msg);
            _logger.InfoFormat("Sending SMS to: {0}, from {1}", phone, from);
            if (_sendMessage.RestException != null)
                _logger.Error("Error sending Twillio SMS:" + _sendMessage.RestException.Message);
            if (_sendMessage.ErrorCode.HasValue)
                _logger.Error("Error sending Twillio SMS, error code:" + _sendMessage.ErrorCode.Value);
            _logger.InfoFormat("Sent SMS to: {0}, sid: {1}, from:{2}", phone, _sendMessage.Sid, from);

            return _sendMessage.Sid;
        }

        private void SendSms(SendInfo info, string content)
        {
            var _from = Options.FromPhone;
            if (info.SmsUseFrom2 ?? false)
                _from = Options.FromPhone2;

            var _sid = SmsSendImpl(_from, info.UserPhone, content);
            if (string.IsNullOrEmpty(_sid) && !(info.SmsUseFrom2 ?? false))
            {
                _sid = SmsSendImpl(Options.FromPhone2, info.UserPhone, content);
                if (!string.IsNullOrEmpty(_sid))
                    info.SmsUseFrom2 = true;
            }
            info.SmsId = _sid;
        }

        private static void SendEmail(MandrillApi api, SendInfo info, string subj, string content)
        {
            LogManager.GetLogger(typeof(EmailWorker)).Info("Sending email to:" + info.UserEmail);
            
            var _task = api.SendMessageTemplate(
                new SendMessageTemplateRequest(new EmailMessage
                                               {
                                                   To = new[] { new EmailAddress(info.UserEmail) },
                                                   FromEmail = "weather.app@sequencing.com",
                                                   Subject = subj,
                                                   TrackClicks = false,
                                                   TrackOpens = false
                                               },
                    MANDRILL_TEMPLATE,
                    new[]
                    {
                        new TemplateContent
                        {
                            Name = "main",
                            Content = content
                        }
                    }));
        }

        private bool IsRightTime(SendInfo info)
        {
            var _now = DateTime.Now;
            if (!info.LastSendDt.HasValue ||
                (info.LastSendDt.HasValue &&
                 DateTime.Today.Subtract(info.LastSendDt.Value.Date).TotalDays >= 1))
            {
                var _weekend = _now.DayOfWeek == DayOfWeek.Saturday || _now.DayOfWeek == DayOfWeek.Sunday;
                if (info.TimeZoneOffset.HasValue)
                {
                    var _finalOffset = -TimeZone.CurrentTimeZone.GetUtcOffset(_now).TotalHours + (double)info.TimeZoneOffset.Value;
                    _now = _now.AddHours(_finalOffset);
                }
                if (!string.IsNullOrEmpty(info.TimeWeekEnd) && _weekend)
                {
                    if (_now.Subtract(DateTime.Parse(info.TimeWeekEnd)).TotalMinutes > 0)
                        return true;
                    return false;
                }
                if (!string.IsNullOrEmpty(info.TimeWeekDay))
                {
                    if (_now.Subtract(DateTime.Parse(info.TimeWeekDay)).TotalMinutes > 0)
                        return true;
                    return false;
                }
                return true;
            }
            return false;
        }

        /// <summary>
        /// Checks all users and sends emails
        /// </summary>
        public void CheckAllAndSendEmails()
        {
            using (var _ctx = new WeatherAppDbEntities())
            {
                var _api = new MandrillApi(Options.MandrillApi);
                var _infos =
                    _ctx.SendInfoes.Where(info => (info.SendEmail ?? false) || (info.SendSms ?? false)).ToList();
                foreach (var _info in _infos)
                {
                    var _rrb = new RunResultBuilder(_info.UserName, _info.Temperature ?? TemperatureMode.F);
                    if (IsRightTime(_info))
                    {
                        var _weatherWorker = new WeatherWorker(_info.Temperature ?? TemperatureMode.F, _info.UserName);
                        var _weatherDescripton = _weatherWorker.GetWeatherDescripton(_info.City);
                        var _forecastRoot = _weatherWorker.GetForecast10(_info.City);
                        var _jobId = GetJobId(_info);
                        var _riskValue = _rrb.GetRiskValue(_jobId.Item1.ToString(), _jobId.Item2.ToString());
                        var _alertCode = _forecastRoot.alerts.Count == 0 ? "--" : _forecastRoot.alerts[0].type;

                        var _riskDescription = _rrb.GetRiskDescription(_weatherDescripton.Item1, _alertCode,
                            _riskValue.Item1, _riskValue.Item2);
                        var _subj =
                            string.Format("Weather forecast for " +
                                          DateTime.Now.ToString("dddd MMMM d"));
                        if (_info.SendSms ?? false)
                        {
                            string _msg1 = string.Format(".   Today's forecast for {0}: {1}",
                                _info.City, _weatherDescripton.Item2);
                            _msg1 += Environment.NewLine;
                            _msg1 += "Based on the forecast and an analysis of your genes, your personalized recommendation for today is: "
                                     + _riskDescription;
                            SendSms(_info, _msg1);
                            SendOnSiteNotification(_info, _msg1);
                        }
                        if (_info.SendEmail ?? false)
                        {
                            var _sb = new StringBuilder();
                            _sb.Append("<p style='text-align:center'>")
                                .Append(
                                    "Genetically tailored notification from your <a href='https://weather-app.sequencing.com' class='external'>Weather My Way +RTP app</a>")
                                .Append("</p><br/>");
                            _sb.Append("<p style='text-align:center'>");
                            _sb.AppendFormat("Today's forecast for {0}: ", _info.City).Append("</p>");
                            _sb.Append("<p style='text-align:center'>");
                            _sb.Append(_weatherDescripton.Item2).Append("</p><br/>");
                            _sb.Append("<p style='text-align:center'>");
                            _sb.Append("Your personalized recommendation:").Append("</p>");
                            _sb.Append("<p style='text-align:center'>");
                            _sb.Append(_riskDescription).Append("</p>");

                            SendEmail(_api, _info, _subj, _sb.ToString());
                        }

                        _info.LastSendDt = DateTime.Now;
                        _ctx.SaveChanges();
                    }
                }
            }
        }

        private void SendOnSiteNotification(SendInfo info, string msg1)
        {
            var _srv = new BackendServiceFacade(Options.ApiUrl, info.UserName);
            _srv.SendUserNotification(msg1);
        }

        /// <summary>
        /// Sends email notification on enabling it
        /// </summary>
        /// <param name="name"></param>
        public void SendEmailInvite(string name)
        {
            using (var _ctx = new WeatherAppDbEntities())
            {
                var _firstOrDefault = _ctx.SendInfoes.FirstOrDefault(info => info.UserName == name);
                if (_firstOrDefault != null)
                {
                    var _api = new MandrillApi(Options.MandrillApi);
                    var _sb = new StringBuilder();
                    _sb.Append("<p style='text-align:center'>")
                        .Append("Genetically tailored email notifications have been successfully enabled for your <a href='https://weather-app.sequencing.com' class='external'>Weather My Way +RTP app</a>. You will receive your first personalized weather forecast by the time you wake up tomorrow.")
                        .Append("</p><br/>");
                    _sb.Append("<p style='text-align:center'>");
                    _sb.Append("Notification settings may be changed by going to your <a href='https://weather-app.sequencing.com' class='external'>app</a>.  ").Append("</p>");
                    SendEmail(_api, _firstOrDefault, "Email notifications from weather app", _sb.ToString());
                }
            }
        }

        /// <summary>
        /// Sends SMS notification after its enablement
        /// </summary>
        /// <param name="name"></param>
        public void SendSmsInvite(string name)
        {
            using (var _ctx = new WeatherAppDbEntities())
            {
                var _firstOrDefault = _ctx.SendInfoes.FirstOrDefault(info => info.UserName == name);
                if (_firstOrDefault != null)
                {
                    SendSms(_firstOrDefault,
                        "Genetically tailored SMS notifications successfully enabled for your Weather My Way +RTP app. Email apps@sequencing.com if u didn't activate this notification.");
                }
            }
        }
    }
}