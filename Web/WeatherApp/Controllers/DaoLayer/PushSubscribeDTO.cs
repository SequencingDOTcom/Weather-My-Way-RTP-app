using Sequencing.WeatherApp.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Sequencing.WeatherApp.Controllers.DaoLayer
{
    public class PushSubscribeDTO
    {
        public bool pushCheck { get;  set; }
        public string deviceToken { get; set; }
        public DeviceType deviceType { get; set; }
        public string accessToken { get; set; }
        public ApplicationType appType { get; set; }
    }
}