using System;
using System.Linq;
using System.Net;
using Newtonsoft.Json;
using Sequencing.WeatherApp.Models;

namespace Sequencing.WeatherApp.Controllers.WeatherUnderground
{
    /// <summary>
    /// WeatherWorker performs queries against WeatherUnderground service
    /// </summary>
    public class WeatherWorker
    {
        private readonly string userName;

        public WeatherWorker(string userName)
        {
            this.userName = userName;
        }

        private string GetCityCoords(string city)
        {
            using (var _wb = new WebClient())
            {
                var _res = _wb.DownloadString("http://autocomplete.wunderground.com/aq?query=" + city);
                var _root = JsonConvert.DeserializeObject<CityMapResultRoot>(_res);
                if (_root.RESULTS.Count != 0)
                    return _root.RESULTS[0].l;
            }
            return city;
        }

        private Forecast10Root GetForecast10Impl(string city)
        {
            var _cityMapResult = GetCityCoords(city);
            if (_cityMapResult == null)
                return null;
            using (var _wb = new WebClient())
            {
                var _res = _wb.DownloadString(string.Format("http://api.wunderground.com/api/{0}/forecast10day/conditions/alerts/astronomy/q/{1}.json",
                    Options.WUKey, _cityMapResult));
                var _data = JsonConvert.DeserializeObject<Forecast10Root>(_res);
                return _data;
            }
        }


        public CurrentObservationRoot GetConditions(string city)
        {
            var _cityMapResult = GetCityCoords(city);
            using (var _wb = new WebClient())
            {
                var _res = _wb.DownloadString(string.Format("http://api.wunderground.com/api/{0}/conditions/q/{1}.json",
                    Options.WUKey, _cityMapResult));
                var _data = JsonConvert.DeserializeObject<CurrentObservationRoot>(_res);
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