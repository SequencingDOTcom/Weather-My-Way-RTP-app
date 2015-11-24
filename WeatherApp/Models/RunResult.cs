using System;
using Sequencing.WeatherApp.Controllers.WeatherUnderground;

namespace Sequencing.WeatherApp.Models
{
    /// <summary>
    /// Results page model
    /// </summary>
    public class RunResult : CommonData
    {
        public string Weather { get; set; }
        public string Risk { get; set; }
        public string RawRisk { get; set; }
        public CurrentObservationRoot.CurrentObservation CurrentWeather { get; set; }
        public TemperatureMode Temperature { get; set; }
        public DateTime JobDateTime { get; set; }
    }
}