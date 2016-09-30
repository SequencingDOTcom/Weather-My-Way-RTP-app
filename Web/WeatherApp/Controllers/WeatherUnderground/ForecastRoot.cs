using System.Collections.Generic;

namespace Sequencing.WeatherApp.Controllers.WeatherUnderground
{
    public class ForecastRoot
    {
        public Response response { get; set; }
        public Location location { get; set; }
        public Forecast forecast { get; set; }

        public class Features
        {
            public /*int*/string forecast { get; set; }
            public /*int*/string geolookup { get; set; }
        }

        public class Response
        {
            public string version { get; set; }
            public string termsofService { get; set; }
            public Features features { get; set; }
        }

        public class Station
        {
            public string city { get; set; }
            public string state { get; set; }
            public string country { get; set; }
            public string icao { get; set; }
            public string lat { get; set; }
            public string lon { get; set; }
        }

        public class Airport
        {
            public List<Station> station { get; set; }
        }

        public class Station2
        {
            public string neighborhood { get; set; }
            public string city { get; set; }
            public string state { get; set; }
            public string country { get; set; }
            public string id { get; set; }
            public /*double*/string lat { get; set; }
            public /*double*/string lon { get; set; }
            public /*int*/string distance_km { get; set; }
            public /*int*/string distance_mi { get; set; }
        }

        public class Pws
        {
            public List<Station2> station { get; set; }
        }

        public class NearbyWeatherStations
        {
            public Airport airport { get; set; }
            public Pws pws { get; set; }
        }

        public class Location
        {
            public string type { get; set; }
            public string country { get; set; }
            public string country_iso3166 { get; set; }
            public string country_name { get; set; }
            public string state { get; set; }
            public string city { get; set; }
            public string tz_short { get; set; }
            public string tz_long { get; set; }
            public string lat { get; set; }
            public string lon { get; set; }
            public string zip { get; set; }
            public string magic { get; set; }
            public string wmo { get; set; }
            public string l { get; set; }
            public string requesturl { get; set; }
            public string wuiurl { get; set; }
            public NearbyWeatherStations nearby_weather_stations { get; set; }
        }

        public class Forecastday
        {
            public /*int*/string period { get; set; }
            public string icon { get; set; }
            public string icon_url { get; set; }
            public string title { get; set; }
            public string fcttext { get; set; }
            public string fcttext_metric { get; set; }
            public string pop { get; set; }
        }

        public class TxtForecast
        {
            public string date { get; set; }
            public List<Forecastday> forecastday { get; set; }
        }

        public class Date
        {
            public string epoch { get; set; }
            public string pretty { get; set; }
            public /*int*/string day { get; set; }
            public /*int*/string month { get; set; }
            public /*int*/string year { get; set; }
            public /*int*/string yday { get; set; }
            public /*int*/string hour { get; set; }
            public string min { get; set; }
            public /*int*/string sec { get; set; }
            public string isdst { get; set; }
            public string monthname { get; set; }
            public string monthname_short { get; set; }
            public string weekday_short { get; set; }
            public string weekday { get; set; }
            public string ampm { get; set; }
            public string tz_short { get; set; }
            public string tz_long { get; set; }
        }

        public class High
        {
            public string fahrenheit { get; set; }
            public string celsius { get; set; }
        }

        public class Low
        {
            public string fahrenheit { get; set; }
            public string celsius { get; set; }
        }

        public class QpfAllday
        {
            public /*double*/string @in { get; set; }
            public /*int*/string mm { get; set; }
        }

        public class QpfDay
        {
            public /*double*/string @in { get; set; }
            public /*int*/string mm { get; set; }
        }

        public class QpfNight
        {
            public /*double*/string @in { get; set; }
            public /*int*/string mm { get; set; }
        }

        public class SnowAllday
        {
            public /*double*/string @in { get; set; }
            public /*double*/string cm { get; set; }
        }

        public class SnowDay
        {
            public /*double*/string @in { get; set; }
            public /*double*/string cm { get; set; }
        }

        public class SnowNight
        {
            public /*double*/string @in { get; set; }
            public /*double*/string cm { get; set; }
        }

        public class Maxwind
        {
            public /*int*/string mph { get; set; }
            public /*int*/string kph { get; set; }
            public string dir { get; set; }
            public /*int*/string degrees { get; set; }
        }

        public class Avewind
        {
            public /*int*/string mph { get; set; }
            public /*int*/string kph { get; set; }
            public string dir { get; set; }
            public /*int*/string degrees { get; set; }
        }

        public class Forecastday2
        {
            public Date date { get; set; }
            public /*int*/string period { get; set; }
            public High high { get; set; }
            public Low low { get; set; }
            public string conditions { get; set; }
            public string icon { get; set; }
            public string icon_url { get; set; }
            public string skyicon { get; set; }
            public /*int*/string pop { get; set; }
            public QpfAllday qpf_allday { get; set; }
            public QpfDay qpf_day { get; set; }
            public QpfNight qpf_night { get; set; }
            public SnowAllday snow_allday { get; set; }
            public SnowDay snow_day { get; set; }
            public SnowNight snow_night { get; set; }
            public Maxwind maxwind { get; set; }
            public Avewind avewind { get; set; }
            public /*int*/string avehumidity { get; set; }
            public /*int*/string maxhumidity { get; set; }
            public /*int*/string minhumidity { get; set; }
        }

        public class Simpleforecast
        {
            public List<Forecastday2> forecastday { get; set; }
        }

        public class Forecast
        {
            public TxtForecast txt_forecast { get; set; }
            public Simpleforecast simpleforecast { get; set; }
        }

    }
}