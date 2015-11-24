using System;
using System.Linq;
using System.Net;
using Newtonsoft.Json;

namespace Sequencing.WeatherApp.Controllers.WeatherUnderground
{
    public class WeatherWorker
    {
        private readonly TemperatureMode temperature;
        private readonly string userName;

        public WeatherWorker(TemperatureMode temperature, string userName)
        {
            this.temperature = temperature;
            this.userName = userName;
        }

        private CityMapResult GetCityCoords(string city)
        {
            using (var _wb = new WebClient())
            {
                var _res = _wb.DownloadString("http://autocomplete.wunderground.com/aq?query=" + city);
                var _root = JsonConvert.DeserializeObject<CityMapResultRoot>(_res);
                if (_root.RESULTS.Count != 0)
                    return _root.RESULTS[0];
            }
            return null;
        }

        public Tuple<string,string, CurrentObservationRoot.CurrentObservation> GetWeatherDescripton(string city)
        {
            var _cityMapResult = GetCityCoords(city);
            if (_cityMapResult == null)
                return Tuple.Create("",
                    "Unable to locate weather for given city:" + city +
                    ", please provide more specific about your location.", (CurrentObservationRoot.CurrentObservation)null);
            using (var _wb = new WebClient())
            {
                var _res = _wb.DownloadString(string.Format("http://api.wunderground.com/api/{0}/conditions/q/{1}.json",
                    Options.WUKey, _cityMapResult.l));
                var _data = JsonConvert.DeserializeObject<CurrentObservationRoot>(_res);
                if (_data != null && _data.current_observation != null)
                {
                    var _weatherDescripton = _data.current_observation.weather + " " +
                                             (temperature == TemperatureMode.F
                                                 ? _data.current_observation.temp_f + "F"
                                                 : _data.current_observation.temp_c + "C");
                    return Tuple.Create(_data.current_observation.weather, _weatherDescripton, _data.current_observation);
                }
                return Tuple.Create("", "Unable to evaluate conditions, result was:" + _res, (CurrentObservationRoot.CurrentObservation)null);
            }
        }

        public ForecastRoot GetForecast(string city)
        {
            var _cityMapResult = GetCityCoords(city);
            if (_cityMapResult == null)
                return null;
            using (var _wb = new WebClient())
            {
                var _res = _wb.DownloadString(string.Format("http://api.wunderground.com/api/{0}/forecast/q/{1}.json",
                    Options.WUKey, _cityMapResult.l));
                var _data = JsonConvert.DeserializeObject<ForecastRoot>(_res);
                return _data;
            }
        }

        private Forecast10Root GetForecast10Impl(string city)
        {
            var _cityMapResult = GetCityCoords(city);
            if (_cityMapResult == null)
                return null;
            using (var _wb = new WebClient())
            {
                var _res = _wb.DownloadString(string.Format("http://api.wunderground.com/api/{0}/forecast10day/alerts/astronomy/q/{1}.json",
                    Options.WUKey, _cityMapResult.l));
                var _data = JsonConvert.DeserializeObject<Forecast10Root>(_res);
                return _data;
            }
        }

        private const int WEATHER_UPD_SECONDS = 90;

        public Forecast10Root GetForecast10(string city)
        {
            if (!string.IsNullOrEmpty(userName))
            {
                using (var _ctx = new WeatherAppDbEntities())
                {
                    var _si = _ctx.SendInfoes.FirstOrDefault(info => info.UserName == userName);
                    if (_si == null)
                    {
                        _si = SendInfoWorker.CreateDefaults(userName);
                        _ctx.SendInfoes.Add(_si);
                    }
                    if (_si.WeatherUpdateDt.HasValue &&
                        DateTime.Now.Subtract(_si.WeatherUpdateDt.Value).TotalSeconds < WEATHER_UPD_SECONDS
                        && _si.City == city && _si.LastWeatherUpdate != null)
                    {
                        var _deserializeObject = JsonConvert.DeserializeObject<Forecast10Root>(_si.LastWeatherUpdate);
                        if (_deserializeObject.forecast != null)
                        return _deserializeObject;
                    }

                    var _forecast10Impl = GetForecast10Impl(city);
                    if (_forecast10Impl == null)
                        return null;
                    _si.LastWeatherUpdate = JsonConvert.SerializeObject(_forecast10Impl);
                    _si.WeatherUpdateDt = DateTime.Now;
                    _si.City = city;
                    _ctx.SaveChanges();
                    return _forecast10Impl;
                }
            }
            return GetForecast10Impl(city);
        }
    }
}