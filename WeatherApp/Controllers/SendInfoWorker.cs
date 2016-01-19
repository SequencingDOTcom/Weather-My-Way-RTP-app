using System;
using System.Linq;
using Sequencing.WeatherApp.Models;

namespace Sequencing.WeatherApp.Controllers
{
    /// <summary>
    /// Class for SendInfo data updates/retrievals
    /// </summary>
    internal class SendInfoWorker
    {
        private string name;

        public SendInfoWorker(string name)
        {
            this.name = name;
        }

        public SendInfo GetInfo()
        {
            using (var _ctx = new WeatherAppDbEntities())
            {
                SendInfo _firstOrDefault = _ctx.SendInfoes.FirstOrDefault(info => info.UserName == name)
                                           ?? CreateDefaults(name);
                return _firstOrDefault;
            }
        }

        public static SendInfo CreateDefaults(string name)
        {
            return new SendInfo
                   {
                       UserName = name,
                       WeekendMode = WeekEndMode.SendBoth,
                       TimeWeekDay = "6 AM",
                       TimeWeekEnd = "8 AM"
                   };
        }

        private void UpdateImpl(Action<SendInfo> si)
        {
            using (var _ctx = new WeatherAppDbEntities())
            {
                var _firstOrDefault = _ctx.SendInfoes.FirstOrDefault(info => info.UserName == name);
                if (_firstOrDefault == null)
                {
                    _firstOrDefault = new SendInfo { UserName = name };

                    _ctx.SendInfoes.Add(_firstOrDefault);
                }
                si(_firstOrDefault);
                _ctx.SaveChanges();
            }
        }

        public void SetLocation(string city)
        {
            if (!String.IsNullOrEmpty(city))   
                UpdateImpl(delegate(SendInfo info)
                           {
                               info.City = city;
                               info.LastWeatherUpdate = null;
                               info.WeatherUpdateDt = null;
                           });
        }

        public void SetDataFile(string selectedName, string selectedId)
        {
            if (!String.IsNullOrEmpty(selectedName))
                UpdateImpl(info => { info.DataFileName = selectedName;
                                       info.DataFileId = selectedId;
                });
        }

        private decimal ParseOffset(string offset)
        {
            decimal _sign = 1;
            if (offset.StartsWith("-"))
                _sign = -1;
            if (offset.Contains(":"))
            {
                var _strings = offset.Substring(1).Split(':');
                return _sign*(decimal.Parse(_strings[0]) + decimal.Parse(_strings[1])/60);
            }
            else
                return decimal.Parse(offset);
        }

        public InviteChanges SetNotification(bool emailChk, bool smsChk, string email, string phone, string wakeupDay, string wakeupEnd, string tz, string tzOffset, WeekEndMode weekendMode, TemperatureMode temperature)
        {
            var _res = new InviteChanges();
            UpdateImpl(info =>
                       {
                           if (!(info.SendEmail ?? false) && emailChk)
                               _res.SendEmail = true;
                           if (!(info.SendSms ?? false) && smsChk)
                               _res.SendSms = true;
                           info.SendEmail = emailChk;
                           info.SendSms = smsChk;
                           info.UserEmail = email;
                           info.UserPhone = phone;
                           info.TimeWeekDay = wakeupDay;
                           info.TimeWeekEnd = wakeupEnd;
                           if (!string.IsNullOrEmpty(tzOffset))
                               info.TimeZoneOffset = ParseOffset(tzOffset);
                           info.TimeZoneValue = tz;
                           info.WeekendMode = weekendMode;
                           info.Temperature = temperature;
                       });
            return _res;
        }
    }
}