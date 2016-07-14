using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using PushSharp.Apple;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using log4net;
using Sequencing.WeatherApp.Models;
using System.Timers;
using Sequencing.WeatherApp.Controllers.DaoLayer;
using System.Threading;

namespace Sequencing.WeatherApp.Controllers.PushNotification
{
    public class IosPushMessageSender : PushMessageSender
    {
        private ApnsConfiguration config;
        private ApnsServiceBroker apnsBroker;
        public ILog logger = LogManager.GetLogger(typeof(IosPushMessageSender));
        private IPushNotificationService notificationService = new DefaultPushNotificationService();
        private long userId;

        override public DeviceType GetDeviceType()
        {
            return DeviceType.IOS;
        }

        public IosPushMessageSender()
        {
            config = new ApnsConfiguration(PushSharp.Apple.ApnsConfiguration.ApnsServerEnvironment.Production,
                 Options.ApnsCertificateFile, Options.ApnsCertificatePassword);

            SetUpFeedbackServiceTimer(Options.APNSFeedbackServiceRunDelay);

            apnsBroker = new ApnsServiceBroker(config);

            apnsBroker.OnNotificationFailed += (notification, aggregateEx) =>
            {
                aggregateEx.Handle(ex =>
                {
                    if (ex is ApnsNotificationException)
                    {
                        var notificationException = (ApnsNotificationException)ex;

                        var apnsNotification = notificationException.Notification;
                        var statusCode = notificationException.ErrorStatusCode;

                        logger.Error(string.Format("Apple Notification Failed: ID={0}, Code={1}, Token ={2}", apnsNotification.Identifier, statusCode, notification.DeviceToken));
                        System.Diagnostics.Debug.WriteLine(string.Format("Apple Notification Failed: ID={0}, Code={1}, Token ={2}", apnsNotification.Identifier, statusCode, notification.DeviceToken));
                    }
                    else
                    {
                        logger.Error(string.Format("Apple Notification Failed for some unknown reason : {0}, Token = {1}", ex.InnerException, notification.DeviceToken));
                        System.Diagnostics.Debug.WriteLine(string.Format("Apple Notification Failed for some unknown reason : {0}, Token = {1}", ex.InnerException, notification.DeviceToken));
                    }
                        

                    notificationService.Unsubscribe(notification.DeviceToken, userId);

                    return true;
                });
            };

            apnsBroker.OnNotificationSucceeded += (notification) =>
            {
                logger.Info("Notification Successfully Sent to: " + notification.DeviceToken);
                System.Diagnostics.Debug.WriteLine("Notification Successfully Sent to: " + notification.DeviceToken);
            };

            apnsBroker.Start();
        }

        override public void SendPushNotification(string token, string message, Int64 userId)
        {

            this.userId = userId;
            var pushObj = new
            {
                aps = new
                {
                    alert = message,
                    sound = "default",
                    badge = 1
                }
            };

            apnsBroker.QueueNotification(new ApnsNotification
            {
                DeviceToken = token,
                Payload = JObject.Parse(JsonConvert.SerializeObject(pushObj))
            });
        }

        private void CheckAndRemoveExpiredToken()
        {
            try
            {
                var fbs = new FeedbackService(config);
                fbs.FeedbackReceived += (string deviceToken, DateTime timestamp) =>
                {
                    notificationService.Unsubscribe(deviceToken, userId);
                };
                fbs.Check();
            }
            catch (Exception e)
            {
                logger.ErrorFormat("Unable to usubscibed token" + e.Message);
            }
        }

        private void SetUpFeedbackServiceTimer(Int64 delayInHours)
        {
            new System.Threading.Timer(x => { CheckAndRemoveExpiredToken(); },
                null, 60 * 1000 /*initial delay*/, delayInHours * 60 * 1000 /*execution delay*/);
        }
    }
}
