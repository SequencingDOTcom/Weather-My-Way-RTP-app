using Sequencing.WeatherApp.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Sequencing.WeatherApp.Controllers.PushNotification;
using System.Text;
using Sequencing.WeatherApp.Controllers.UserNotification;
using log4net;

namespace Sequencing.WeatherApp.Controllers.DaoLayer
{
    public class UserSettingService : ISettingService
    {
        //public ILog logger = LogManager.GetLogger(typeof(UserSettingService));
        private MSSQLDaoFactory factory = new MSSQLDaoFactory();
        private OAuthTokenDaoFactory oauthFactory = new OAuthTokenDaoFactory();

        

        public SendInfo GetInfo(string name)
        {
            using (var _ctx = new WeatherAppDbEntities())
            {
                SendInfo _firstOrDefault = _ctx.SendInfoes.FirstOrDefault(info => info.UserName == name)
                                           ?? new SendInfo(name);
                return _firstOrDefault;
            }
        }

        public void SetUserLocationExt(string city, string userToken)
        {
            string userName = oauthFactory.GetOAuthTokenDao().getUser(userToken).userName;
            SetUserLocation(city, userName);
        }

        public void SetUserLocation(string city, string name)
        {
            if (String.IsNullOrEmpty(city))
                return;

            /*
            SendInfo existingInfo = factory.GetSendInfoDao().Find(name);

            if (existingInfo == null)
            {
                factory.GetSendInfoDao().Insert(new SendInfo
                {
                    UserName = name,
                    City = city,
                    WeatherUpdateDt = null,
                    LastWeatherUpdate = null
                });
                return;
            }

            existingInfo.City = city;
            existingInfo.WeatherUpdateDt = null;
            existingInfo.LastWeatherUpdate = null;
            */

            factory.GetSendInfoDao().Update(new SendInfo
            {
                UserName = name,
                City = city,
                WeatherUpdateDt = null,
                LastWeatherUpdate = null
            });
        }

        public void SetUserDataFileExt(string selectedName, string selectedId, string token)
        {
            string userName = oauthFactory.GetOAuthTokenDao().getUser(token).userName;
            SetUserDataFile(selectedName, selectedId, userName);
        }

        public void SetUserDataFile(string selectedName, string selectedId, string name)
        {
            if (String.IsNullOrEmpty(selectedName))
                return;

            /*
            SendInfo existingInfo = factory.GetSendInfoDao().Find(name);

            if (existingInfo == null)
            {
                factory.GetSendInfoDao().Insert(new SendInfo {
                    UserName = name,
                    DataFileName = selectedName,
                    DataFileId = selectedId,
                });
                return;
            }

            existingInfo.DataFileName = selectedName;
            existingInfo.DataFileId = selectedId;
            */

            factory.GetSendInfoDao().Update(new SendInfo
            {
                UserName = name,
                DataFileName = selectedName,
                DataFileId = selectedId,
            });
        }


        public void UpdateUserSettings(SendInfo newInfo)
        {
            SendInfo existingInfo = factory.GetSendInfoDao().Find(newInfo.UserName);

            bool shouldSendEmail = ShouldSendInitialEmail(existingInfo, newInfo.UserEmail, newInfo.SendEmail.Value);
            bool shouldSendSms = ShouldSendInitialSms(existingInfo, newInfo.UserPhone, newInfo.SendSms.Value);

            existingInfo.Merge(newInfo);

            var _emailWorker = new EmailWorker();
            if (shouldSendEmail)
                _emailWorker.SendEmailInvite(existingInfo.UserName);

            if (shouldSendSms)
                _emailWorker.SendSmsInvite(existingInfo);

            UpdateUserSettingsImpl(existingInfo);
        }

        /// <summary>
        /// Updates user settings in the database
        /// </summary>
        /// <param name="newInfo"></param>
        protected SendInfo UpdateUserSettingsImpl(SendInfo newInfo)
        {
            if (newInfo == null)
            {
                factory.GetSendInfoDao().Insert(newInfo);
                return newInfo;
            }

            return factory.GetSendInfoDao().Update(newInfo);
        }

        /// <summary>
        /// Determines whether initial invitation email should be sent to a user
        /// </summary>
        /// <param name="info"></param>
        /// <param name="email"></param>
        /// <param name="emailChk"></param>
        /// <returns></returns>
        private bool ShouldSendInitialEmail(SendInfo info, string email, bool emailChk)
        {
            bool isAlreadySubscribed = (info.SendEmail ?? false);

            if (!emailChk)
                return false;

            if (!isAlreadySubscribed)
                return true;

            bool emailMatches = email.Equals(info.UserEmail);

            return !emailMatches;
        }

        /// <summary>
        /// Determines whether initial invitation SMS should be sent to a user
        /// </summary>
        /// <param name="info"></param>
        /// <param name="phone"></param>
        /// <param name="smsChk"></param>
        /// <returns></returns>
        private bool ShouldSendInitialSms(SendInfo info, string phone, bool smsChk)
        {
            bool isAlreadySubscribed = (info.SendSms ?? false);

            if (!smsChk)
                return false;

            if (!isAlreadySubscribed)
                return true;

            bool phoneMatches = phone.Equals(info.UserPhone);

            return !phoneMatches;
        }

        public decimal ParseTimeZoneOffset(string offset)
        {
            decimal _sign = 1;
            if (offset.StartsWith("-"))
                _sign = -1;
            if (offset.Contains(":"))
            {
                var _strings = offset.Substring(1).Split(':');
                return _sign * (decimal.Parse(_strings[0]) + decimal.Parse(_strings[1]) / 60);
            }
            else
                return decimal.Parse(offset);
        }


        /// <summary>
        /// ///////////////////////////////////////////////////////////////////
        /// </summary>
        /// <param name="userId"></param>
        /// <param name="token"></param>
        /// <param name="deviceType"></param>

        public void SubscribePushNotification(long userId, string token, DeviceType deviceType)
        {
            IPushNotificationService notificationService = new DefaultPushNotificationService();

            System.Diagnostics.Debug.WriteLine(string.Format("SubscribePushNotification: userId {0}, token {1}, deviceType {2}", userId, token, deviceType));

            if (notificationService.IsTokenSubscribed(token) == false)
            {
                notificationService.SubscribeDeviceToken(userId, token, deviceType);
                notificationService.Send(userId, deviceType, token, Options.NotificationMessage);
            }
            else
                System.Diagnostics.Debug.WriteLine(string.Format("User with token: {0} is already subscibed", token));
        }
    }
}