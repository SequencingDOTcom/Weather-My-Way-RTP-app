using log4net;
using Newtonsoft.Json;
using Sequencing.WeatherApp.Controllers.DaoLayer;
using Sequencing.WeatherApp.Controllers.PushNotification;
using Sequencing.WeatherApp.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.Timers;

namespace Sequencing.WeatherApp.Service
{
    public class PushNotificationSender 
    {
        IPushNotificationService notificationService = new DefaultPushNotificationService();
        private MSSQLDaoFactory factory = new MSSQLDaoFactory();
        ILog logger = LogManager.GetLogger(typeof(PushNotificationSender));
        Timer aTimer = new System.Timers.Timer(30 * 60 * 1000);
        private const int TAKE_RECORDS = 10;

        /*protected override void CurrentDomain_OnUnhandledException(object sender, UnhandledExceptionEventArgs e)
        {
            LogManager.GetLogger(typeof(PushNotificationSender)).Fatal(e.ExceptionObject);
        }*/

        public void Init()
        {           
            logger.Debug("Setting up timer " + DateTime.Now);
            aTimer.Elapsed += new ElapsedEventHandler(SendPush);
            aTimer.Start();
        }
        public void Stop()
        {
            logger.Debug("Aborting timer " + DateTime.Now);
          
            aTimer.Stop();
        }

        /* protected override void ProcessImpl()
         {

         }*/

        private void SendPush(object source, ElapsedEventArgs e)
        {
            logger.Info("Sending push notification "+ DateTime.Now);
            int skip = 0;
            int countDeviceTokens = factory.GetDeviceTokenDao().CountDeviceInfo();
            logger.Info("Count devices " + countDeviceTokens);

            while (countDeviceTokens > 0)
            {
                var deviceInfoList = factory.GetDeviceTokenDao().SelectTokens(skip, TAKE_RECORDS);
                foreach (var device in deviceInfoList)
                {
                    try
                    {
                        if (device.appVersion == null)
                            continue;
                       
                        PushMessageSender sender = null;
                        switch (device.deviceType)
                        {
                            case DeviceType.IOS:
                                sender = new IosPushMessageSender(device.applicationId, "{\"aps\":{\"content-available\":1}}");
                                break;

                            case DeviceType.Android:
                                sender = new AndroidPushMessageSender(device.applicationId, "{\"message\":\"" + "refreshBadge" + "\"}");
                                break;

                        }
                        logger.InfoFormat("Sending silent push to user: {0}, device token: {1}: ", device.userId, device.token);
                        sender.SendPushNotification(device.token, device.userId.Value);
                    }
                    catch (Exception ex) {
                        logger.ErrorFormat("Error sending push to {0}. {1}", device.token, ex);
                    }

                }
                skip += TAKE_RECORDS;
                countDeviceTokens -= TAKE_RECORDS;
            }

                
            //var tokens = factory.GetDeviceTokenDao().GetDeviceTokensByUserId(userIds);

            /*var localTokenInfo1 = new DeviceInfo()
            {
                userId = 25,
                deviceType = DeviceType.IOS,
                token = "356c92bc177c3a16d0d3c8ae4072cc98b3f871e7ec3217fe37a980ce635ac9f3",
                applicationId = ApplicationType.Mobile
            };
            var localTokenInfo2 = new DeviceInfo()
            {
                userId = 25,
                deviceType = DeviceType.IOS,
                token = "9a845a27f64fba7a09bca2a3d29bde06e7c29a6cbe752ddea375a092be70d0d7",
                applicationId = ApplicationType.Mobile
            };
            var localTokenInfo3 = new DeviceInfo()
            {
                userId = 25,
                deviceType = DeviceType.IOS,
                token = "7a7d7d635c9f68497717a9f58a4063fc79502691918a17e4001a00d4971d603c",
                applicationId = ApplicationType.Mobile
            };
            var localTokenInfo4 = new DeviceInfo()
            {
                userId = 25,
                deviceType = DeviceType.IOS,
                token = "5baf60f746ee2093e35300d5e03937faa6acf5a94a4c2cbd2b2bd942310883a6",
                applicationId = ApplicationType.Mobile
            };
            var localTokenInfo5 = new DeviceInfo()
            {
                userId = 25,
                deviceType = DeviceType.IOS,
                token = "9948d02b68a8642b6fcfef5bc5c4ee5d550063fdf95a3a80d4d4371e9d46de83",
                applicationId = ApplicationType.Mobile
            };
            var localTokenInfo6 = new DeviceInfo()
            {
                userId = 25,
                deviceType = DeviceType.IOS,
                token = "2aa753522953213aa9bd75fcaaacbecf130e98fd3748fc33fe2d223eb6dc4b3d",
                applicationId = ApplicationType.Mobile
            };
            var localTokenInfo7 = new DeviceInfo()
            {
                userId = 25,
                deviceType = DeviceType.IOS,
                token = "f734e841110359e2afafac078f5195f11170b8bfdc5a0e69d4a0eee9d9a5b9e7",
                applicationId = ApplicationType.Mobile
            };
            var localTokenInfo9 = new DeviceInfo()
            {
                userId = 25,
                deviceType = DeviceType.Android,
                token = "fuv3-o7AwYU:APA91bFt9uIYXe-fsSdHImzUDCWgSGqrCEV-jKCEbjklDr8uN1yaXLNMc3QIpNqZSkjTa6E8fpv_oN0u53ObCnSyQrkeRwIH9K1DNYvRqqmsgUxfaOmYgFouiTSDr715rwev9bXDv3Zn",
                applicationId = ApplicationType.Mobile
            };
            var localTokenInfo10 = new DeviceInfo()
            {
                userId = 25,
                deviceType = DeviceType.Android,
                token = "d8DCGRZU-XE:APA91bEE2b8rddkMs5NuMHChiAWMgu3rWZPoXaaAegEuN7Mcg-q9CyuRYqjroZ1Ancm_821GiRYb4JZ-iChd-kknIzqZKbTEMJCEtLIVK1kgqllM56tWFYaMdD7CieWOpDh3Amc90oFm",
                applicationId = ApplicationType.Mobile
            };
          

            //f734e841110359e2afafac078f5195f11170b8bfdc5a0e69d4a0eee9d9a5b9e7
            tokens.Add(localTokenInfo1);
            tokens.Add(localTokenInfo2);
            tokens.Add(localTokenInfo3);
            tokens.Add(localTokenInfo4);
            tokens.Add(localTokenInfo5);
            tokens.Add(localTokenInfo6);
            tokens.Add(localTokenInfo7);
            tokens.Add(localTokenInfo9);
            tokens.Add(localTokenInfo10);*/

        }
    }
}
