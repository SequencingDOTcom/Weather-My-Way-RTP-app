using Sequencing.WeatherApp.Controllers.WeatherUnderground;

namespace Sequencing.WeatherApp.Models
{
    /// <summary>
    /// Base model data
    /// </summary>
    public class CommonData
    {
        public SharedContext Context { get; set; }
        public Forecast10Root Forecast { get; set; }
    }
}