using System;
using System.IO;
using System.Linq;
using System.Web.Mvc;
using Newtonsoft.Json;
using Sequencing.WeatherApp.Controllers.OAuth;
using Sequencing.WeatherApp.Models;
using Sequencing.WeatherApp.Controllers.DaoLayer;

namespace Sequencing.WeatherApp.Controllers
{
    /// <summary>
    /// Provides access for storing/retrieving settings for native (not-web) clients (iphone/android)
    /// </summary>
    public class ExternalController : Controller
    {
        MSSQLDaoFactory mssqlDao = new MSSQLDaoFactory();

        [AllowAnonymous]
        public ActionResult Settings()
        {
            string _userName = ExtractUserName();
            if (_userName != null)
            {              
                    SendInfo _info = mssqlDao.GetSendInfoDao().Find(_userName);

                    return Json(ExternalSendInfo.Create(_info), JsonRequestBehavior.AllowGet);
            }
            return Json(new ExternalSendInfo(), JsonRequestBehavior.AllowGet);
        }

        [AllowAnonymous]
        [HttpPost]
        public ActionResult Settings(string par)
        {
            string _userName = ExtractUserName();
            Stream req = Request.InputStream;
            req.Seek(0, SeekOrigin.Begin);
            string json = new StreamReader(req).ReadToEnd();
            var _userInfo = JsonConvert.DeserializeObject<ExternalSendInfo>(json);
            if (_userName != null)
            {
                    SendInfo _info = mssqlDao.GetSendInfoDao().Find(_userName);
                    _info.SendEmail = _userInfo.SendEmail;
                    _info.SendSms = _userInfo.SendSms;
                    _info.UserEmail = _userInfo.UserEmail;
                    _info.UserPhone = _userInfo.UserPhone;
                    _info.City = _userInfo.City;
                    _info.DataFileName = _userInfo.DataFileName;
                    _info.DataFileId = _userInfo.DataFileId;
                    _info.TimeWeekDay = _userInfo.TimeWeekDay;
                    _info.TimeWeekEnd = _userInfo.TimeWeekEnd;
                    _info.TimeZoneOffset = _userInfo.TimeZoneOffset;
                    _info.WeekendMode = _userInfo.WeekendMode;
                    _info.Temperature = _userInfo.Temperature;

                    mssqlDao.GetSendInfoDao().Update(_info);

                return Json(ExternalSendInfo.Create(_info), JsonRequestBehavior.AllowGet);
            }
            return Json(new ExternalSendInfo(), JsonRequestBehavior.AllowGet);
        }

        private string ExtractUserName()
        {
            var _s = Request.Headers["Authorization"];
            if (_s != null && _s.StartsWith("OAuth"))
            {
                var _strings = _s.Split(' ');
                var _token = _strings[1];

                var _userName = new AuthWorker(Options.OAuthUrl, Options.OAuthRedirectUrl, Options.OAuthSecret, Options.OAuthAppId).GetUserInfo(_token).username;
                return _userName;
            }
            return null;
        }

        public class ExternalSendInfo
        {
            public Nullable<bool> SendEmail { get; set; }
            public Nullable<bool> SendSms { get; set; }
            public string UserEmail { get; set; }
            public string UserPhone { get; set; }
            public string City { get; set; }
            public string DataFileName { get; set; }
            public string DataFileId { get; set; }
            public string TimeWeekDay { get; set; }
            public string TimeWeekEnd { get; set; }
            public Nullable<decimal> TimeZoneOffset { get; set; }
            public Nullable<WeekEndMode> WeekendMode { get; set; }
            public Nullable<TemperatureMode> Temperature { get; set; }

            public static ExternalSendInfo Create(SendInfo info)
            {
                return new ExternalSendInfo
                {
                    City = info.City,
                    DataFileId = info.DataFileId,
                    DataFileName = info.DataFileName,
                    SendEmail = info.SendEmail,
                    SendSms = info.SendSms,
                    Temperature = info.Temperature,
                    TimeWeekDay = info.TimeWeekDay,
                    TimeWeekEnd = info.TimeWeekEnd,
                    TimeZoneOffset = info.TimeZoneOffset,
                    UserEmail = info.UserEmail,
                    UserPhone = info.UserPhone,
                    WeekendMode = info.WeekendMode
                };
            }
        }
    }

}