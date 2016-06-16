using System.Collections.Generic;
using System.Net;
using Newtonsoft.Json;
using Sequencing.WeatherApp.Models;

namespace Sequencing.WeatherApp.Controllers.WeatherUnderground
{
    /// <summary>
    /// LocationVerifier performs check whether user provided location string will be compatible with WeatherUnderground service
    /// </summary>
    public class LocationVerifier
    {
        private readonly SharedContext ctx;

        public LocationVerifier(SharedContext ctx)
        {
            this.ctx = ctx;
        }

        public class RootObject
        {
            public List<RESULT> RESULTS { get; set; }

            public class RESULT
            {
                public string name { get; set; }
                public string type { get; set; }
                public string c { get; set; }
                public string zmw { get; set; }
                public string tz { get; set; }
                public string tzs { get; set; }
                public string l { get; set; }
                public string ll { get; set; }
                public string lat { get; set; }
                public string lon { get; set; }
            }
        }
    }
}