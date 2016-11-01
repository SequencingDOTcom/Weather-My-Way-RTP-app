using System;
using System.Linq;
using System.Net;
using Newtonsoft.Json;
using Sequencing.WeatherApp.Models;
using Sequencing.WeatherApp.Controllers.DaoLayer;

namespace Sequencing.WeatherApp.Controllers.WeatherUnderground
{
    /// <summary>
    /// WeatherWorker performs queries against WeatherUnderground service
    /// </summary>
    public class WeatherWorker
    {
        private readonly string userName;

        MSSQLDaoFactory mssqlDao = new MSSQLDaoFactory();
        ISettingService setting = new UserSettingService();

        public WeatherWorker(string userName)
        {
            this.userName = userName;
        }

        private Forecast10Root GetForecast10Impl(string city)
        {
            using (var _wb = new WebClient())
            {
                var _res = _wb.DownloadString(string.Format("http://api.wunderground.com/api/{0}/forecast10day/conditions/alerts/astronomy/q/{1}.json",
                    Options.WUKey, city));
                var _data = JsonConvert.DeserializeObject<Forecast10Root>(_res);
                return _data;
            }
        }


        public static CurrentObservationRoot GetConditions(string city)
        {
            using (var _wb = new WebClient())
            {
                var _res = _wb.DownloadString(string.Format("http://api.wunderground.com/api/{0}/conditions/q/{1}.json",
                    Options.WUKey, city));
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
                    var _si = _ctx.SendInfo.FirstOrDefault(info => info.UserName == userName);
                    if (_si == null)
                    {
                        _si = new SendInfo(userName);
                        _ctx.SendInfo.Add(_si);
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

        /// <summary>
        /// Converts location name to its ID
        /// </summary>
        /// <param name="obj"></param>
        /// <param name="cityName"></param>
        /// <returns></returns>
        public static string ConvertFromNameToID(string cityName)
        {
            var weatherInfo = WeatherParser(cityName);
            if (weatherInfo != null)
                return weatherInfo.l;
            return null;
        }

        /// <summary>
        /// Converts location ID to its name
        /// </summary>
        /// <param name="cityID"></param>
        /// <returns></returns>
        public static string ConvertFromIDToName(string cityID)
        {
            if (cityID != null)
                return GetConditions(cityID).current_observation.display_location.full;
            else

                return null;
        }

        public static LocationVerifier.RootObject.RESULT WeatherParser(string city)
        {
            var currentName = city.Split(new char[] { ',' });
            if (currentName.Length > 0)
                city = currentName[0];

            using (var _wb = new WebClient())
            {
                var _res = _wb.DownloadString("http://autocomplete.wunderground.com/aq?format=JSON&query=" + city);
                var rootObj = JsonConvert.DeserializeObject<LocationVerifier.RootObject>(_res);
                if (city != null)
                    foreach (LocationVerifier.RootObject.RESULT res in rootObj.RESULTS)
                    {
                        var isEqual = res.name.Split(new char[] {','})[0].Equals(city,
                            StringComparison.InvariantCultureIgnoreCase);
                        if (isEqual && res.type.Equals("city"))
                            return res;
                    }
                return null;
            }
        }
    }
}