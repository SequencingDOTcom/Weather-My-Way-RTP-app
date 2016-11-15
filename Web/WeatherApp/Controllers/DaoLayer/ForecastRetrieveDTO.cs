using Newtonsoft.Json;
using Newtonsoft.Json.Converters;
using Sequencing.WeatherApp.Controllers.AppChain;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Sequencing.WeatherApp.Controllers.DaoLayer
{
    public class ForecastRetrieveDTO
    {
        public RegularQualitativeResultType melanomaRisk { get; set; }
        public bool vitaminD { set; get; }
        public string language { set; get;  }
        public string authToken { set; get; }
        public ForecastRequest [] forecastRequest { set; get; }
        public int appId { set; get; }
    }

    public class ForecastRequest
    {
        public DateTime date { set; get; }
        public string weather { set; get; }
        public string alertCode { set; get; }
    }

    public class ForecastResponse
    {
        public string gtForecast { set; get; }
        public string date { set; get; }
    }
}