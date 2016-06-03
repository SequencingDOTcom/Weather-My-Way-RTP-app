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
        public abstract void SendPushNotification(string token, string message, Int64 userId);
        public abstract DeviceType GetDeviceType();
    }
}
