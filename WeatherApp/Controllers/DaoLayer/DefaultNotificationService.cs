using log4net;
using Sequencing.WeatherApp.Controllers.PushNotification;
using Sequencing.WeatherApp.Controllers.UserNotification;
using Sequencing.WeatherApp.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Web;

namespace Sequencing.WeatherApp.Controllers.DaoLayer
{
    public class DefaultPushNotificationService : IPushNotificationService
    {
        private OAuthTokenDaoFactory oauthFactory = new OAuthTokenDaoFactory();
        private MSSQLDaoFactory mssqlDaoFactory = new MSSQLDaoFactory();
        private ISettingService settingsService = new UserSettingService();

        private log4net.ILog logger = LogManager.GetLogger(typeof(DefaultPushNotificationService));

        public void Subscribe(string deviceToken, DeviceType deviceType, string accessToken)
        {
            string userName = oauthFactory.GetOAuthTokenDao().getUser(accessToken).userName;

            // checking for token validity
            if (userName != null)
            {
                var sendInfo = mssqlDaoFactory.GetSendInfoDao().Find(userName);

                if (sendInfo != null)
                    settingsService.SubscribePushNotification(sendInfo.Id, deviceToken, deviceType);
            }
            else
                //log.InfoFormat("Invalid access token");
                System.Diagnostics.Debug.WriteLine("Invalid access token");
        }

        public void Unsubscribe(string token)
        {
            mssqlDaoFactory.GetDeviceTokenDao().DeleteToken(token);
        }

        public void Send(Int64 userId, DeviceType deviceType, string token, string message)
        {
            PushMessageSender pushMessageSender = GetPushMessageSender(deviceType);

            if (pushMessageSender == null)
            {
                logger.Error(string.Format("Device type: {0} is not supported", deviceType));
                return;
            }

            pushMessageSender.SendPushNotification(token, message, userId);
        }

        public void Send(Int64 userId, string message)
        {
            List<DeviceToken> deviceTokensInfo = mssqlDaoFactory.GetDeviceTokenDao().Select(userId);

            foreach (DeviceToken token in deviceTokensInfo)
            {
                Send(userId, token.deviceType.Value, token.token, message);
            }
        }

        public void SubscribeDeviceToken(Int64 userId, string token, DeviceType deviceType)
        {
            try
            {
                if (IsTokenSubscribed(token))
                    return;

                DeviceToken devInfo = new DeviceToken
                {
                    userId = userId,
                    subscriptionDate = DateTime.Now.Date,
                    deviceType = deviceType,
                    token = token
                };

                mssqlDaoFactory.GetDeviceTokenDao().SaveToken(devInfo);
            }
            catch (Exception e)
            {
                logger.Error(e);
            }

        }

        public bool IsUserSubscribed(Int64 userId)
        {
            if (mssqlDaoFactory.GetDeviceTokenDao().SelectCount(userId) > 0)
                return true;

            return false;
        }

        public bool IsTokenSubscribed(string token)
        {
            if (mssqlDaoFactory.GetDeviceTokenDao().FindToken(token) == null)
                return false;

            return true;
        }

        public List<string> FetchUserDeviceTokens(Int64 userId, DeviceType deviceType)
        {
            return mssqlDaoFactory.GetDeviceTokenDao().GetUserTokens(userId, deviceType).ToList();
        }

        public void RefreshDeviceToken(string oldId, string newId)
        {
            mssqlDaoFactory.GetDeviceTokenDao().UpdateToken(oldId, newId);
        }

        private PushMessageSender GetPushMessageSender(DeviceType deviceType)
        {
            switch (deviceType)
            {
                case DeviceType.IOS:
                    return new IosPushMessageSender();

                case DeviceType.Android:
                    return new AndroidPushMessageSender();
            }

            return null;
        }


    }
}