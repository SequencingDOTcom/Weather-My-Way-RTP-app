using Sequencing.WeatherApp.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Sequencing.WeatherApp.Controllers.DaoLayer
{
    public interface IDeviceTokenDao
    {
        void SaveToken(DeviceInfo tokenInfo);
        void DeleteToken(string token, long userId);
        DeviceInfo FindToken(string token);
        void UpdateToken(string oldId, string newId);
        List<DeviceInfo> Select(Int64 userId);
        List<string> GetUserTokens(Int64 userId, DeviceType deviceType);
        int SelectCount(Int64 userId);
        long GetUserIdByName(string userName);
    }
}