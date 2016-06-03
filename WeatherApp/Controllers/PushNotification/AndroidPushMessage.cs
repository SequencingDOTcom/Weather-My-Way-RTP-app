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

        public AndroidPushMessageSender()
        {
            config = new GcmConfiguration(Options.GCMSenderId, Options.DeviceAuthToken, null);

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

                        log.Error($"GCM Notification Failed: ID={gcmNotification.MessageId}, Desc={description}");
                    }
                    else if (ex is GcmMulticastResultException)
                    {
                        var multicastException = (GcmMulticastResultException)ex;

                        foreach (var succeededNotification in multicastException.Succeeded)
                        {
                            log.Error($"GCM Notification Failed: ID={succeededNotification.MessageId}");
                        }

                        foreach (var failedKvp in multicastException.Failed)
                        {
                            var n = failedKvp.Key;
                            var e = failedKvp.Value;

                            log.Error($"GCM Notification Failed: ID={n.MessageId}, Desc={e.InnerException}");
                        }

                    }
                    else if (ex is DeviceSubscriptionExpiredException)
                    {
                        var expiredException = (DeviceSubscriptionExpiredException)ex;

                        var oldId = expiredException.OldSubscriptionId;
                        var newId = expiredException.NewSubscriptionId;

                        log.Error($"Device RegistrationId Expired: {oldId}");
                        log.Error($"Device RegistrationId Changed To: {newId}");

                        if (!string.IsNullOrWhiteSpace(newId))
                        {
                            notificationService.RefreshDeviceToken(oldId, newId);

                            log.Error($"Device RegistrationId Changed To: {newId}");
                        }
                        else
                            notificationService.Unsubscribe(oldId);
                    }
                    else if (ex is RetryAfterException)
                    {
                        var retryException = (RetryAfterException)ex;

                        log.Error($"GCM Rate Limited, don't send more until after {retryException.RetryAfterUtc}");
                    }
                    else
                    {
                        log.Error($"GCM Notification Failed for some unknown reason");
                    }

                    log.Error($"FAiled for:" + string.Join(",", notification.RegistrationIds));

                    return true;
                });
            };

            gcmBroker.OnNotificationSucceeded += (notification) =>
            {
                log.Info($"Success for:" + string.Join(",", notification.RegistrationIds));
            };

            gcmBroker.Start();
        }

        override public void SendPushNotification(string token, string message, Int64 userId)
        {
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