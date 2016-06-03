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
        public void ChangeNotification(bool emailChk = true, bool smsChk = true, string email = "anna.derkatch@yandex.com", string phone = "+380969064204",
            string wakeupDay = "6:00 AM", string wakeupEnd = "6:00 AM", string timezoneSelect = "Etc/GMT-3", string timezoneOffset = "1.00000",
            WeekEndMode weekendMode = WeekEndMode.SendBoth, TemperatureMode temperature = TemperatureMode.C, string token = "1d9822269d3ab0089e0f004f5c8979ff5d43dad1")
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
                info.TimeZoneOffset = 2.00000m;

            settingsService.UpdateUserSettings(info);
        }


        [HttpPost]
        public void SubscribePushNotification(bool pushCheck = true, string deviceToken = "041c639650e9b50d6850f3d214a9b014828489a2a695d68c0c0e6270a09a56ee", DeviceType deviceType = DeviceType.IOS, string accessToken = "56ccdfdc16e06d86fbb25aa076a48bb3ee73481c")
        {
            if (pushCheck)
                pushService.Subscribe(deviceToken, deviceType, accessToken);
            else
                pushService.Unsubscribe(deviceToken);
        }

        [HttpPost]
        public void SaveFile(string selectedId = "ADS:40852", string selectedName = "Craig Venter - A maverick and pioneer of modern day genetics", string token = "3124c0b9ae0302e822a5d7d9e03b22942a6e71bb")
        {
            settingsService.SetUserDataFileExt(selectedName, selectedId, token);
        }

        [HttpPost]
        public void SaveLocation(string city = "Vinnitsa, Ukraine", string token = "3124c0b9ae0302e822a5d7d9e03b22942a6e71bb")
        {
            settingsService.SetUserLocationExt(city, token);
        }
    }
}