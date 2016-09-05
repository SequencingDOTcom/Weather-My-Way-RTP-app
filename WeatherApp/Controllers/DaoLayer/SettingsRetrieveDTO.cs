using Sequencing.WeatherApp.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Sequencing.WeatherApp.Controllers.DaoLayer
{
    public class SettingsRetrieveDTO
    {
        public string accessToken { set; get; }
        public string expiresIn { set; get; }
        public string tokenType { set; get; }
        public string scope { set; get; }
        public string refreshToken { set; get; }
        public string oldDeviceToken { set; get; }
        public string newDeviceToken { set; get; }
        public bool sendPush { set; get; }
        public DeviceType deviceType { set; get; }
        public ApplicationType applicationId { set; get; }
    }
}