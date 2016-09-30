using System.Web.Mvc;
using System.Web.Security;
using Sequencing.WeatherApp.Controllers.OAuth;
using Sequencing.WeatherApp.Controllers.UserNotification;
using Sequencing.WeatherApp.Models;
using Sequencing.WeatherApp.Controllers.DaoLayer;
using Sequencing.WeatherApp.Controllers.WeatherUnderground;

namespace Sequencing.WeatherApp.Controllers
{
    /// <summary>
    /// Settings page controller
    /// </summary>
    public class SettingsController : ControllerBase
    {
        ISettingService settingService = new UserSettingService();

        // GET: Settings
        [Authorize]
        public ActionResult Index()
        {
            var _name = User.Identity.Name;
            var _sendInfo = settingService.GetInfo(_name);
            ViewBag.SelectedLocation = WeatherWorker.ConvertFromIDToName(_sendInfo.City);
            ViewBag.EmailSend = _sendInfo.SendEmail ?? false;
            ViewBag.SmsSend = _sendInfo.SendSms ?? false;
            ViewBag.Email = _sendInfo.UserEmail;
            ViewBag.Phone = _sendInfo.UserPhone;
            ViewBag.AuthDt = new UserAuthWorker().GetCurrent().AuthDt;
            ViewBag.DataFileName = _sendInfo.DataFileName;
            ViewBag.wakeupDay = _sendInfo.TimeWeekDay;
            ViewBag.wakeupEnd = _sendInfo.TimeWeekEnd;
            ViewBag.tzOffset = _sendInfo.TimeZoneOffset;
            ViewBag.tzValue = _sendInfo.TimeZoneValue;
            ViewBag.CountryCode = _sendInfo.CountryCode;

            var _values = new[]
                          {
                              new {Id = WeekEndMode.SendEmail.ToString(), Name = "Only send email notifications on weekend"},
                              new {Id = WeekEndMode.SendSms.ToString(), Name = "Only send txt msg (SMS) notifications on weekend"},
                              new {Id = WeekEndMode.SendBoth.ToString(), Name = "Send notifications on weekends"},
                              new {Id = WeekEndMode.None.ToString(), Name = "Do not send any notifications on weekends"},
                              new {Id = WeekEndMode.Push.ToString(), Name = "Only send push notifications on weekend"},
                              new {Id = WeekEndMode.PushAndEmail.ToString(), Name = "Send push and email notifications on weekend"},
                              new {Id = WeekEndMode.PushAndSms.ToString(), Name = "Send push and msg (SMS) notifications on weekend"},
                              new {Id = WeekEndMode.All.ToString(), Name = "Send all notifications on weekend"},
                          };
            ViewBag.weekendModeList = new SelectList(_values, "Id", "Name", _sendInfo.WeekendMode.ToString());
            ViewBag.weekendMode = _sendInfo.WeekendMode;
            ViewBag.temperature = _sendInfo.Temperature;
            ViewBag.temperatureList = new SelectList(new[]
                                                 {
                                                     new {Id = TemperatureMode.F.ToString(), Name = "F"},
                                                     new {Id = TemperatureMode.C.ToString(), Name = "C"},
                                                 }, "Id", "Name", _sendInfo.Temperature.ToString());
            return View(new CommonData());
        }


        [Authorize]
        [HttpPost]
        public ActionResult ChangeNotification(bool emailChk, bool smsChk, string email, string phone,
            string wakeupDay, string wakeupEnd, string timezoneSelect, string timezoneOffset,
            WeekEndMode weekendMode, TemperatureMode temperature, string countryCode)
        {
            SendInfo info = new SendInfo()
            {
                UserName = User.Identity.Name,
                SendEmail = emailChk,
                SendSms = smsChk,
                UserEmail = email,
                UserPhone = phone,
                TimeWeekDay = wakeupDay,
                TimeWeekEnd = wakeupEnd,
                TimeZoneValue = timezoneSelect,
                WeekendMode = weekendMode,
                Temperature = temperature,
                CountryCode = countryCode
            };

            if (!string.IsNullOrEmpty(timezoneOffset))
                info.TimeZoneOffset = settingService.ParseTimeZoneOffset(timezoneOffset);

            settingService.UpdateUserSettings(info);

            return RedirectToAction("GoToResults", "Default");
        }

        [Authorize]
        public ActionResult RevokeAccess()
        {
            FormsAuthentication.SignOut();
            return RedirectToAction("Startup", "Default");
        }
    }
}