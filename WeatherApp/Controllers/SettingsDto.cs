using Sequencing.WeatherApp.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

namespace Sequencing.WeatherApp.Controllers
{
    public class SettingsDto
    {
        public bool emailChk { get; set; }
        public bool smsChk { get; set; }
        public string email { get; set; }
        public string phone { get; set; }
        public string wakeupDay { get; set; }
        public string wakeupEnd { get; set; }
        public string timezoneSelect { get; set; }
        public string timezoneOffset { get; set; }
        public WeekEndMode weekendMode { get; set; }
        public TemperatureMode temperature { get; set; }
        public string token { get; set; }
        public string countryCode { get; set; }
    }
}
