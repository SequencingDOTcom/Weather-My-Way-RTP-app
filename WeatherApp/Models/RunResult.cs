using System;
using Sequencing.WeatherApp.Controllers.WeatherUnderground;

namespace Sequencing.WeatherApp.Models
{
    /// <summary>
    /// Personalized forecast results page model
    /// </summary>
    public class RunResult : CommonData
    {
        public string Weather { get; set; }
        public string Risk { get; set; }
        public string RawRisk { get; set; }
        public Forecast10Root.CurrentObservation CurrentWeather { get; set; }
        public TemperatureMode Temperature { get; set; }
        public DateTime JobDateTime { get; set; }
    }
}