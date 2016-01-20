using System.Collections.Generic;

namespace Sequencing.WeatherApp.Controllers.WeatherUnderground
{
    /// <summary>
    /// WU data wrapper
    /// </summary>
    public class CityMapResultRoot
    {
        public List<CityMapResult> RESULTS { get; set; }
    }
}