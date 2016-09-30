using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using log4net;
using Mandrill;
using Mandrill.Models;
using Mandrill.Requests.Messages;
using Sequencing.WeatherApp.Controllers.AppChain;
using Sequencing.WeatherApp.Controllers.WeatherUnderground;
using Sequencing.WeatherApp.Models;
using Twilio;
using Sequencing.WeatherApp.Controllers.DaoLayer;

namespace Sequencing.WeatherApp.Controllers.UserNotification
{
    /// <summary>
    /// User notifications implementation sender: emails/sms/on site notification
    /// </summary>
    public class EmailWorker
    {
        private const string MANDRILL_TEMPLATE = "weather-my-way-notification";
        IPushNotificationService notificationService = new DefaultPushNotificationService();
        ILog _logger = LogManager.GetLogger(typeof(EmailWorker));

        private Tuple<long, long> GetJobId(SendInfo info)
        {
            var _srv = new SqApiServiceFacade(Options.ApiUrl, info.UserName);
            var _rs = _srv.StartAppChain(SqApiServiceFacade.MELANOMA_APP_CHAIN_ID, new Dictionary<string, string> { { "dataSourceId", info.DataFileId } });
            var _rs2 = _srv.StartAppChain(SqApiServiceFacade.VITD_APP_CHAIN_ID, new Dictionary<string, string> { { "dataSourceId", info.DataFileId } });

            while (true)
            {
                var _appStatus = _srv.CheckAppChainStatus(Convert.ToInt64(_rs.jobId));
                var _appStatus2 = _srv.CheckAppChainStatus(Convert.ToInt64(_rs2.jobId));
                if (_appStatus == "Completed" && _appStatus2 == "Completed")
                    break;
                Thread.Sleep(5000);
            }

            return Tuple.Create(_rs.jobId, _rs2.jobId);
        }

        private string SmsSendImpl(string from, string phone, string msg)
        {
            var twilio = new TwilioRestClient(Options.TwilioAccountSid, Options.TwilioAuthToken);

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
            _logger.InfoFormat("SID: {0} ", _sid);
        }

        private static void SendEmail(MandrillApi api, SendInfo info, string subj, string content)
        {
            LogManager.GetLogger(typeof(EmailWorker)).Info("Sending email to:" + info.UserEmail);

            var _task = api.SendMessageTemplate(
                new SendMessageTemplateRequest(new EmailMessage
                {
                    To = new[] { new EmailAddress(info.UserEmail) },
                    FromEmail = "forecast@weathermyway.rocks",
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
        /// Checks all users and sends emails/sms/on-site-alerts when appropriate
        /// </summary>
        public void CheckAllAndSendEmails()
        {
            using (var _ctx = new WeatherAppDbEntities())
            {
                var _api = new MandrillApi(Options.MandrillApi);
                var _infos =
                    _ctx.SendInfo.Where(info => (info.SendEmail ?? false) || (info.SendSms ?? false)).ToList();
                foreach (var _info in _infos)
                {
                    var _mode = _info.Temperature ?? TemperatureMode.F;
                    var _rrb = new PersonalizedForecastResultBuilder(_info.UserName, _mode);
                    LogManager.GetLogger(GetType()).Debug("Processing sendInfo:"+_info.Id);
                    if (IsRightTime(_info))
                    {
                        LogManager.GetLogger(GetType()).Debug("Processing sendInfo, time was right:" + _info.Id);
                        var _weatherWorker = new WeatherWorker(_info.UserName);
                        var _forecastRoot = _weatherWorker.GetForecast10(_info.City);
                        LogManager.GetLogger(GetType()).Debug("Received forecast:" + _info.Id);
                        if (string.IsNullOrEmpty(_info.DataFileId))
                            continue;
                        var _jobId = GetJobId(_info);
                        LogManager.GetLogger(GetType()).Debug("Started job:" + _info.Id);

                        var _riskValue = _rrb.GetAppChainResultingRisks(_jobId.Item1.ToString(), _jobId.Item2.ToString());
                        var _alertCode = _forecastRoot.alerts.Count == 0 ? "--" : _forecastRoot.alerts[0].type;

                        var _riskDescription = _rrb.GetPersonalizedRiskDescription(_forecastRoot.forecast.simpleforecast.forecastday[0].conditions, _alertCode, _riskValue);
                        var _subj =
                            string.Format("Forecast for " +
                                          DateTime.Now.ToString("dddd MMMM d"));
                        var _city = WeatherWorker.ConvertFromIDToName(_info.City);
                        var _time = _forecastRoot.current_observation.observation_time;
                        var _todayForecast = _mode == TemperatureMode.F ?
                            _forecastRoot.forecast.txt_forecast.forecastday[0].fcttext :
                            _forecastRoot.forecast.txt_forecast.forecastday[0].fcttext_metric;
                        var _currentObservation = _forecastRoot.current_observation.weather + " and " + (_mode == TemperatureMode.F
                                                 ? _forecastRoot.current_observation.temp_f + "F"
                                                 : _forecastRoot.current_observation.temp_c + "C");

                        if (_info.SendSms ?? false)
                        {
                            LogManager.GetLogger(GetType()).Debug("Sending sms:" + _info.Id);
                            SendSmsNotification(_info, _city, _todayForecast, _currentObservation, _riskDescription);
                        }

                        if (notificationService.IsUserSubscribed(_info.Id))
                        {
                            LogManager.GetLogger(GetType()).Debug("Sending push:" + _info.Id);
                            SendPushNotification(_info, _city, _todayForecast, _currentObservation, _riskDescription);
                        }

                        if (_info.SendEmail ?? false)
                        {
                            LogManager.GetLogger(GetType()).Debug("Sending email:" + _info.Id);
                            SendEmailNotification(_info, _city, _todayForecast, _currentObservation, _riskDescription, _forecastRoot, _mode, _api, _subj);
                        }

                        _info.LastSendDt = DateTime.Now;
                        _ctx.SaveChanges();
                    }
                }
            }
        }

        private void SendPushNotification(SendInfo _info, string _city, string _todayForecast, string _currentObservation, string _riskDescription)
        {
            string _msg1 = string.Format("Your genetically tailored forecast for {0}: {1} Right now it's {2}. {3}",
                _city, _todayForecast, _currentObservation, _riskDescription);

            notificationService.Send(_info.Id, _msg1);

           
        }

        private void SendSmsNotification(SendInfo _info, string _city, string _todayForecast, string _currentObservation, string _riskDescription)
        {
            string _msg1 = string.Format("Your genetically tailored forecast for {0}: {1} Right now it's {2}. {3}",
                               _city, _todayForecast, _currentObservation, _riskDescription);
            SendSms(_info, _msg1);
            SendOnSiteNotification(_info, _msg1);
        }

        private void SendEmailNotification(SendInfo _info, string _city, string _todayForecast, string _currentObservation, string _riskDescription,
            Forecast10Root _forecastRoot, TemperatureMode _mode, MandrillApi _api, string _subj)
        {
            var _sb = new StringBuilder();
            _sb.Append("<p style='text-align:center'>")
                .AppendFormat(
                    "Genetically tailored notification from your <a href='{0}' class='external'>Weather My Way +RTP</a> app",
                    Options.BaseSiteUrl)
                .Append("</p>");
            _sb.Append("<p style='text-align:center'><strong>");
            _sb.AppendFormat("Current weather for {0}", _city).Append("</strong></p>");
            _sb.Append("<p style='text-align:center'>");
            _sb.Append(_currentObservation).Append("</p><br/>");
            _sb.Append("<p style='text-align:center'>");
            _sb.Append("<strong>Today's forecast</strong>").Append("</p>");
            _sb.Append("<p style='text-align:center'>");
            _sb.Append(_todayForecast).Append("</p><br/>");
            _sb.Append("<p style='text-align:center'>");
            _sb.Append("<strong>Your genetically tailored forecast</strong>").Append("</p>");
            _sb.Append("<p style='text-align:center'>");
            _sb.Append(_riskDescription).Append("</p><br/>");
            _sb.Append("<p style='text-align:center'><strong>Extended forecast</strong></p>");
            for (int _idx = 1; _idx <
                Math.Min(5, _forecastRoot.forecast.txt_forecast.forecastday.Count); _idx++)
            {
                _sb.Append("<p style='text-align:center'>");
                _sb.Append(_forecastRoot.forecast.txt_forecast.forecastday[_idx].title).Append(":");
                _sb.Append(_mode == TemperatureMode.F ?
                    _forecastRoot.forecast.txt_forecast.forecastday[_idx].fcttext :
                    _forecastRoot.forecast.txt_forecast.forecastday[_idx].fcttext_metric).Append("</p>");
            }
            SendEmail(_api, _info, _subj, _sb.ToString());
        }

        private void SendOnSiteNotification(SendInfo info, string msg1)
        {
            var _srv = new SqApiServiceFacade(Options.ApiUrl, info.UserName);
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
                var _firstOrDefault = _ctx.SendInfo.FirstOrDefault(info => info.UserName == name);
                if (_firstOrDefault != null)
                {
                    var _api = new MandrillApi(Options.MandrillApi);
                    var _sb = new StringBuilder();
                    _sb.Append("<p style='text-align:left'>")
                        .AppendFormat(
                            "Genetically tailored email notifications have been successfully enabled for your <a href='{0}' class='external'>Weather My Way +RTP</a> app. You will receive your first personalized weather forecast by the time you wake up tomorrow.",
                            "https://sequencing.com/weather-my-way-rtp")
                        .Append("</p>");
                    _sb.Append("<p style='text-align:left'>");
                    _sb.AppendFormat("Notification settings may be changed by going to your app.").Append("</p>");
                    SendEmail(_api, _firstOrDefault, "Email notifications from weather app", _sb.ToString());
                }
            }
        }

        /// <summary>
        /// Sends SMS notification after its enablement
        /// </summary>
        /// <param name="name"></param>
        public void SendSmsInvite(SendInfo info)
        {
            string message = "Genetically tailored SMS notifications successfully enabled for your Weather My Way + RTP app. Email apps@weathermyway.rocks if you didn't activate this notification.";
            SendSms(info, message);
        }
    }
}