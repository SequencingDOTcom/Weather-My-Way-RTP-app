using PushSharp.Apple;
using Sequencing.WeatherApp.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Sequencing.WeatherApp.Controllers.PushNotification
{
    public abstract class PushMessageSender
    {
        /// <summary>
        /// Sends user push notification
        /// </summary>
        /// <param name="token"></param>
        /// <param name="message"></param>
        /// <param name="userId"></param>
        public abstract void SendPushNotification(string token, Int64 userId);
        public abstract DeviceType GetDeviceType();
    }
}
