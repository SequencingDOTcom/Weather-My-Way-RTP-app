using Sequencing.WeatherApp.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Sequencing.WeatherApp.Controllers.DaoLayer
{
    public interface IDeviceTokenDao
    {
        void SaveToken(DeviceToken tokenInfo);
        void DeleteToken(string token);
        DeviceToken FindToken(string token);
        void UpdateToken(string oldId, string newId);
        List<DeviceToken> Select(Int64 userId);
        List<string> GetUserTokens(Int64 userId, DeviceType deviceType);
        int SelectCount(Int64 userId);
    }
}