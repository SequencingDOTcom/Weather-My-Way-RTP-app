using System.Collections.Generic;
using System.Net;
using Newtonsoft.Json;
using Sequencing.WeatherApp.Models;

namespace Sequencing.WeatherApp.Controllers.WeatherUnderground
{
    public class LocationVerifier
    {
        private readonly SharedContext ctx;

        public LocationVerifier(SharedContext ctx)
        {
            this.ctx = ctx;
        }

        public bool IsLocationValid(string city)
        {
           using (var _wb = new WebClient())
            {
                var _res = _wb.DownloadString("http://autocomplete.wunderground.com/aq?query=" + city);
                var _rootObject = JsonConvert.DeserializeObject<RootObject>(_res);
                if (_rootObject.RESULTS.Count != 0)
                    return true;
                var _currentObservationRoot = new WeatherWorker(ctx.UserName).GetConditions(city);
                if (_currentObservationRoot.current_observation != null)
                    return true;
                return false;
            }   
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