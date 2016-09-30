using Sequencing.WeatherApp.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Sequencing.WeatherApp.Controllers.DaoLayer
{
    public interface IPushNotificationService
    {
        void Subscribe(string deviceToken, DeviceType deviceType, string accessToken, ApplicationType? appType);
        void Unsubscribe(string token, long userId);
        void Send(Int64 userId, DeviceType deviceType, string token, string message, ApplicationType? appType);
        void Send(Int64 userId, string message);
        void SubscribeDeviceToken(string token, DeviceType deviceType, long userId, ApplicationType? appType);
        bool IsUserSubscribed(Int64 userId);
        bool IsTokenSubscribed(string token);
        void RefreshDeviceToken(string oldId, string newId);
    }
}