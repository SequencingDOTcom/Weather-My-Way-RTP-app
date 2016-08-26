using log4net;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using PushSharp.Core;
using PushSharp.Google;
using Sequencing.WeatherApp.Controllers.DaoLayer;
using Sequencing.WeatherApp.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Sequencing.WeatherApp.Controllers.PushNotification
{
    public class AndroidPushMessageSender : PushMessageSender
    {
        private GcmConfiguration config;
        private GcmServiceBroker gcmBroker;
        private IPushNotificationService notificationService = new DefaultPushNotificationService();
        private ILog log = LogManager.GetLogger(typeof(AndroidPushMessageSender));
        private string devToken;
        private long userId;

        public AndroidPushMessageSender(ApplicationType? appType)
        {
            if (appType == ApplicationType.Tablet)
                config = new GcmConfiguration(Options.GCMSenderIdTablet, Options.DeviceAuthTokenTablet, null);
            else
                config = new GcmConfiguration(Options.GCMSenderIdMobile, Options.DeviceAuthTokenMobile, null);

            gcmBroker = new GcmServiceBroker(config);

            gcmBroker.OnNotificationFailed += (notification, aggregateEx) =>
            {
                aggregateEx.Handle(ex =>
                {
                    if (ex is GcmNotificationException)
                    {
                        var notificationException = (GcmNotificationException)ex;
                        var gcmNotification = notificationException.Notification;
                        var description = notificationException.Description;

                        notificationService.Unsubscribe(devToken, userId);

                        log.Error(string.Format("GCM Notification Failed: ID={0}, Desc={1}", gcmNotification.MessageId, description));
                    }
                    else if (ex is GcmMulticastResultException)
                    {
                        var multicastException = (GcmMulticastResultException)ex;

                        foreach (var succeededNotification in multicastException.Succeeded)
                        {
                            log.Error(string.Format("GCM Notification Failed: ID={0}", succeededNotification.MessageId));
                        }

                        foreach (var failedKvp in multicastException.Failed)
                        {
                            var n = failedKvp.Key;
                            var e = failedKvp.Value;

                            log.Error(string.Format("GCM Notification Failed: ID={0}, Desc={1}", n.MessageId, e.InnerException));
                        }
                        notificationService.Unsubscribe(devToken, userId);
                    }
                    else if (ex is DeviceSubscriptionExpiredException)
                    {

                        var expiredException = (DeviceSubscriptionExpiredException)ex;

                        var oldId = expiredException.OldSubscriptionId;
                        var newId = expiredException.NewSubscriptionId;

                        log.Error(string.Format("Device RegistrationId Expired: {0}", oldId));
                        log.Error(string.Format("Device RegistrationId Changed To: {0}", newId));

                        if (!string.IsNullOrWhiteSpace(newId))
                        {
                            notificationService.Unsubscribe(oldId, userId);

                            log.Error(string.Format("Device RegistrationId Changed To: {0}", newId));
                        }
                        else
                            notificationService.Unsubscribe(oldId, userId);
                    }
                    else if (ex is RetryAfterException)
                    {
                        var retryException = (RetryAfterException)ex;

                        log.Error(string.Format("GCM Rate Limited, don't send more until after {0}", retryException.RetryAfterUtc));
                    }
                    else
                    {
                        log.Error("GCM Notification Failed for some unknown reason");
                    }

                    log.Error("Failed for:" + string.Join(",", notification.RegistrationIds));

                    return true;
                });
            };

            gcmBroker.OnNotificationSucceeded += (notification) =>
            {
                log.Info("Success for:" + string.Join(",", notification.RegistrationIds));
            };

            gcmBroker.Start();
        }

        override public void SendPushNotification(string token, string message, Int64 userId)
        {
            devToken = token;
            this.userId = userId;

            var pushObj = new
            {
                message = message,
            };

            gcmBroker.QueueNotification(new GcmNotification
            {
                RegistrationIds = new List<string> {
                        token
                    },
                Data = JObject.Parse(JsonConvert.SerializeObject(pushObj))
            });
        }

        public override DeviceType GetDeviceType()
        {
            return DeviceType.Android;
        }
    }
}