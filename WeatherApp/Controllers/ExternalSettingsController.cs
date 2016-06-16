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

    /// <summary>
    /// Controller used in mobile app
    /// </summary>
    public class ExternalSettingsController : ControllerBase
    {
        public ILog log = LogManager.GetLogger(typeof(ExternalSettingsController));

        MSSQLDaoFactory factory = new MSSQLDaoFactory();
        IPushNotificationService pushService = new DefaultPushNotificationService();
        OAuthTokenDaoFactory oauthFactory = new OAuthTokenDaoFactory();
        ISettingService settingsService = new UserSettingService();

        /// <summary>
        /// Change user notifications in database
        /// </summary>
        /// <param name="emailChk"></param>
        /// <param name="smsChk"></param>
        /// <param name="email"></param>
        /// <param name="phone"></param>
        /// <param name="wakeupDay"></param>
        /// <param name="wakeupEnd"></param>
        /// <param name="timezoneSelect"></param>
        /// <param name="timezoneOffset"></param>
        /// <param name="weekendMode"></param>
        /// <param name="temperature"></param>
        /// <param name="token"></param>
        [HttpPost]
        public void ChangeNotification(bool emailChk, bool smsChk, string email, string phone,
            string wakeupDay, string wakeupEnd, string timezoneSelect, string timezoneOffset,
            WeekEndMode weekendMode, TemperatureMode temperature, string token)
        {
            string name = oauthFactory.GetOAuthTokenDao().getUser(token).username;

            if (name != null)
            {
                SendInfo info = new SendInfo()
                {
                    UserName = name,
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
            else
                log.InfoFormat("Invalid access token");
        }

        /// <summary>
        /// Subscribe user to get push notification
        /// </summary>
        /// <param name="pushCheck"></param>
        /// <param name="deviceToken"></param>
        /// <param name="deviceType"></param>
        /// <param name="accessToken"></param>
        [HttpPost]
        public void SubscribePushNotification(bool pushCheck, string deviceToken, DeviceType deviceType, string accessToken)
        {
            if (pushCheck)
                pushService.Subscribe(deviceToken, deviceType, accessToken);
            else
                pushService.Unsubscribe(deviceToken);
        }

        /// <summary>
        /// Set new file to database
        /// </summary>
        /// <param name="selectedId"></param>
        /// <param name="selectedName"></param>
        /// <param name="token"></param>
        [HttpPost]
        public void SaveFile(string selectedId, string selectedName, string token)
        {
            settingsService.SetUserDataFileExt(selectedName, selectedId, token);
        }

        /// <summary>
        /// Change location
        /// </summary>
        /// <param name="city"></param>
        /// <param name="token"></param>
        [HttpPost]
        public void SaveLocation(string city, string token)
        {
            settingsService.SetUserLocationExt(city, token);
        }


        /// <summary>
        /// Retrieve user settings from database
        /// </summary>
        /// <param name="accessToken"></param>
        /// <param name="expiresIn"></param>
        /// <param name="tokenType"></param>
        /// <param name="scope"></param>
        /// <param name="refreshToken"></param>
		[HttpPost]
        public SendInfo RetrieveUserSettings(string accessToken, string expiresIn, string tokenType, string scope, string refreshToken)
        {
            TokenInfo tokenInfo = new TokenInfo()
            {
                access_token = accessToken,
                expires_in = expiresIn,
                token_type = tokenType,
                scope = scope,
                refresh_token = refreshToken
            };

            SendInfo sendInfo = settingsService.GetUserSettings(tokenInfo);

            return sendInfo;
        }
    }
}