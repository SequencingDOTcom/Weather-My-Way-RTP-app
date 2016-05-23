using Sequencing.WeatherApp.Controllers.UserNotification;
using Sequencing.WeatherApp.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web;
using System.Web.Mvc;

namespace Sequencing.WeatherApp.Controllers
{
    public class BaseSettingsController : ControllerBase
    {
        protected string SubscribeUserNotification(string userName, bool emailChk, bool smsChk, string email, string phone,
            string wakeupDay, string wakeupEnd, string timezoneSelect, string timezoneOffset, WeekEndMode weekendMode, TemperatureMode temperature)
        {
            StringBuilder builder = new StringBuilder();

            var _inviteChanges = new SendInfoWorker(userName).SetNotification(emailChk, smsChk, email, phone,
                   wakeupDay, wakeupEnd, timezoneSelect, timezoneOffset, weekendMode, temperature);
            var _emailWorker = new EmailWorker();
            if (_inviteChanges.SendEmail)
            {
                _emailWorker.SendEmailInvite(userName);
                builder.Append("Genetically tailored email notifications have been successfully enabled. ");
            }
            if (_inviteChanges.SendSms)
                builder.Append(_emailWorker.SendSmsInvite(userName));

            return builder.ToString();
        }
    }
}