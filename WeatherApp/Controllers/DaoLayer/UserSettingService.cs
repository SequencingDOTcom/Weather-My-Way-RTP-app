using Sequencing.WeatherApp.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Sequencing.WeatherApp.Controllers.PushNotification;
using System.Text;
using Sequencing.WeatherApp.Controllers.UserNotification;
using log4net;
using Sequencing.WeatherApp.Controllers.OAuth;

namespace Sequencing.WeatherApp.Controllers.DaoLayer
{
    public class UserSettingService : ISettingService
    {
        public ILog logger = LogManager.GetLogger(typeof(UserSettingService));
        private MSSQLDaoFactory factory = new MSSQLDaoFactory();
        private OAuthTokenDaoFactory oauthFactory = new OAuthTokenDaoFactory();


        public SendInfo GetInfo(string name)
        {
            using (var _ctx = new WeatherAppDbEntities())
            {
                SendInfo _firstOrDefault = _ctx.SendInfo.FirstOrDefault(info => info.UserName == name)
                                           ?? new SendInfo(name);
                return _firstOrDefault;
            }
        }

        /// <summary>
        /// Extension for user location set
        /// </summary>
        /// <param name="city"></param>
        /// <param name="userToken"></param>
        public void SetUserLocationExt(string city, string userToken)
        {
            string userName = oauthFactory.GetOAuthTokenDao().getUser(userToken).username;
            if (userName != null)
                SetUserLocation(city, userName);
            else
                throw new ApplicationException(string.Format("Invalid access token {0}", userToken));
        }


        /// <summary>
        /// Set user location
        /// </summary>
        /// <param name="city"></param>
        /// <param name="name"></param>
        public void SetUserLocation(string city, string name)
        {
            if (String.IsNullOrEmpty(city))
                return;

            factory.GetSendInfoDao().Update(new SendInfo
            {
                UserName = name,
                City = city,
                WeatherUpdateDt = null,
                LastWeatherUpdate = null
            });
        }

        /// <summary>
        /// Extension for user file change
        /// </summary>
        /// <param name="selectedName"></param>
        /// <param name="selectedId"></param>
        /// <param name="token"></param>
        public void SetUserDataFileExt(string selectedName, string selectedId, string token)
        {
            string userName = oauthFactory.GetOAuthTokenDao().getUser(token).username;

            if (userName != null)
                SetUserDataFile(selectedName, selectedId, userName);
            else
                throw new ApplicationException(string.Format("Invalid access token {0}", token));
        }

        /// <summary>
        /// Change user file
        /// </summary>
        /// <param name="selectedName"></param>
        /// <param name="selectedId"></param>
        /// <param name="name"></param>
        public void SetUserDataFile(string selectedName, string selectedId, string name)
        {
            if (String.IsNullOrEmpty(selectedName))
                return;

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

        public string DeviceTokenSetting(string oldToken, string newToken, bool sendPush, DeviceType deviceType, string accessToken, long userId)
        {
            try
            {
                if (sendPush == true && newToken != null && oldToken == null)
                {
                    ProcessSubscribe(newToken, deviceType, accessToken);
                    logger.InfoFormat("Device token {0} successfully subscribed", newToken);
                    return string.Format("Device token {0} successfully subscribed", newToken);
                }
                else if (sendPush == true && newToken != null && oldToken != null)
                {
                    return ProcessUpdate(oldToken, newToken, userId, deviceType);
                }

                return "Settings successfully retrieved";
            }
            catch (Exception e)
            {
                throw new ApplicationException(e.Message);
            }
        }

        private string ProcessUpdate(string oldToken, string newToken, long userId, DeviceType deviceType)
        {
            try
            {
                IPushNotificationService notificationSrv = new DefaultPushNotificationService();

                if (notificationSrv.IsTokenSubscribed(oldToken))
                {
                    if (!newToken.Equals(oldToken))
                    {
                        notificationSrv.RefreshDeviceToken(oldToken, newToken);
                        logger.InfoFormat("Device token {0} successfully updated with new token {1}", oldToken, newToken);
                        return string.Format("Device token {0} successfully updated with new token {1}", oldToken, newToken);
                    }
                        
                }
                else if (!notificationSrv.IsTokenSubscribed(newToken))
                {
                    notificationSrv.SubscribeDeviceToken(newToken, deviceType, userId);
                    return string.Format("New device token {0} successfully inserted in database", newToken);
                }
                return null;
            }
            catch (Exception e)
            {
                throw new ApplicationException(e.Message);
            }
        }

        private void ProcessSubscribe(string newToken, DeviceType deviceType, string accessToken)
        {
            try
            {
                IPushNotificationService notificationSrv = new DefaultPushNotificationService();

                if (!notificationSrv.IsTokenSubscribed(newToken))
                    notificationSrv.Subscribe(newToken, deviceType, accessToken);
                else
                    throw new ApplicationException("Device already subscribed");
            }
            catch (Exception e)
            {
                throw new ApplicationException(e.Message);
            }
        }

        /// <summary>
        /// Retrieve user settings from database
        /// </summary>
        /// <param name="userToken"></param>
        /// <returns></returns>
        private SendInfo GetUserSettings(TokenInfo tokenInfo)
        {
            string userName = oauthFactory.GetOAuthTokenDao().getUser(tokenInfo.access_token).username;

            if (userName != null)
            {
                SendInfo info = factory.GetSendInfoDao().Find(userName);

                if (info == null)
                {
                    info = factory.GetSendInfoDao().Insert(new SendInfo(userName));
                    if (factory.GetUserInfoDao().SelectCount(userName) == 0)
                        new UserAuthWorker().CreateNewUserToken(tokenInfo);
                }
                return info;
            }
            throw new ApplicationException(string.Format("Invalid access token {0}", tokenInfo.access_token));
        }

        public SendInfo RetrieveSettings(string accessToken, string expiresIn, string tokenType, string scope, string refreshToken)
        {
            TokenInfo tokenInfo = new TokenInfo()
            {
                access_token = accessToken,
                expires_in = expiresIn,
                token_type = tokenType,
                scope = scope,
                refresh_token = refreshToken
            };

            SendInfo info = GetUserSettings(tokenInfo);
            info.LastWeatherUpdate = null;

            return info;
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
            try
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
            catch (Exception e)
            {
                throw new ApplicationException(string.Format("Unable to parse time zone"), e);
            }
        }


        /// <summary>
        /// Subscribes push notifications
        /// </summary>
        /// <param name="userId"></param>
        /// <param name="token"></param>
        /// <param name="deviceType"></param>

        public void SubscribePushNotification(string token, DeviceType deviceType, SendInfo info)
        {
            try
            {
                IPushNotificationService notificationService = new DefaultPushNotificationService();

                if (notificationService.IsTokenSubscribed(token) == false)
                {
                    notificationService.SubscribeDeviceToken(token, deviceType, info.Id);
                    notificationService.Send(info.Id, deviceType, token, Options.NotificationMessage);
                }
                else
                    throw new ApplicationException("Device already subscribed");
            }
            catch (Exception e)
            {
                throw new ApplicationException(e.Message);
            }
        }
    }
}