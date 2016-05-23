using Sequencing.WeatherApp.Controllers.UserNotification;
using Sequencing.WeatherApp.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Web;
using System.Web.Mvc;
using Sequencing.WeatherApp.Controllers.OAuth;


namespace Sequencing.WeatherApp.Controllers
{
    public class ExternalSettingsController : BaseSettingsController
    {
        [HttpPost]
        public JsonResult ChangeNotification(bool emailChk, bool smsChk, string email, string phone,
            string wakeupDay, string wakeupEnd, string timezoneSelect, string timezoneOffset,
            WeekEndMode weekendMode, TemperatureMode temperature, string token)
        {           
             string userName = new AuthWorker(Options.OAuthUrl, Options.OAuthRedirectUrl, Options.OAuthSecret,
                 Options.OAuthAppId).GetUserName(token);

             if (userName != null)
             {
                 string message = SubscribeUserNotification(userName, emailChk, smsChk, email, phone,
                     wakeupDay, wakeupEnd, timezoneSelect, timezoneOffset, weekendMode, temperature);

                 return Json(new { Type = "Result", Message = message }, JsonRequestBehavior.AllowGet);
             }
             else
                 return Json(new { Type = "Error", Message = "Invalid token" }, JsonRequestBehavior.AllowGet);
        }
    }
}