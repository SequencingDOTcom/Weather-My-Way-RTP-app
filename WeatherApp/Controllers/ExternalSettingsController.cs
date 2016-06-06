using Sequencing.WeatherApp.Controllers.UserNotification;
using Sequencing.WeatherApp.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Web;
using System.Web.Mvc;
using Sequencing.WeatherApp.Controllers.OAuth;
using log4net;
using Sequencing.WeatherApp.Controllers.DaoLayer;

namespace Sequencing.WeatherApp.Controllers
{
    public class ExternalSettingsController : ControllerBase
    {
        public ILog log = LogManager.GetLogger(typeof(ExternalSettingsController));

        MSSQLDaoFactory factory = new MSSQLDaoFactory();
        IPushNotificationService pushService = new DefaultPushNotificationService();
        OAuthTokenDaoFactory oauthFactory = new OAuthTokenDaoFactory();
        ISettingService settingsService = new UserSettingService();

        [HttpPost]
        public void ChangeNotification(bool emailChk, bool smsChk, string email, string phone,
            string wakeupDay, string wakeupEnd, string timezoneSelect, string timezoneOffset,
            WeekEndMode weekendMode, TemperatureMode temperature, string token)
        {
            SendInfo info = new SendInfo()
            {
                UserName = oauthFactory.GetOAuthTokenDao().getUser(token).userName,
                SendEmail = emailChk,
                SendSms = smsChk,
                UserEmail = email,
                UserPhone = phone,
                TimeWeekDay = wakeupDay,
                TimeWeekEnd = wakeupEnd,
                TimeZoneValue = timezoneSelect,
                WeekendMode = weekendMode,
                Temperature = temperature
            };

            if (!string.IsNullOrEmpty(timezoneOffset))
                info.TimeZoneOffset = settingsService.ParseTimeZoneOffset(timezoneOffset);

            settingsService.UpdateUserSettings(info);
        }

        [HttpPost]
        public void SubscribePushNotification(bool pushCheck, string deviceToken, DeviceType deviceType, string accessToken)
        {
            if (pushCheck)
                pushService.Subscribe(deviceToken, deviceType, accessToken);
            else
                pushService.Unsubscribe(deviceToken);
        }

        [HttpPost]
        public void SaveFile(string selectedId, string selectedName, string token)
        {
            settingsService.SetUserDataFileExt(selectedName, selectedId, token);
        }

        [HttpPost]
        public void SaveLocation(string city, string token)
        {
            settingsService.SetUserLocationExt(city, token);
        }
    }
}