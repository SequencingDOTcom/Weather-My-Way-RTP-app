using Sequencing.WeatherApp.Controllers.UserNotification;
using Sequencing.WeatherApp.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Net;
using System.Web;
using System.Web.Mvc;
using Sequencing.WeatherApp.Controllers.OAuth;
using log4net;
using Sequencing.WeatherApp.Controllers.DaoLayer;
using Newtonsoft.Json;

namespace Sequencing.WeatherApp.Controllers
{

    /// <summary>
    /// Controller used in mobile app
    /// </summary>
    public class ExternalSettingsController : ControllerBase
    {
        public ILog log = LogManager.GetLogger(typeof(ExternalSettingsController));

        MSSQLDaoFactory factory = new MSSQLDaoFactory();
        IPushNotificationService pushService = new DefaultPushNotificationService();
        OAuthTokenDaoFactory oauthFactory = new OAuthTokenDaoFactory();
        ISettingService settingsService = new UserSettingService();

        /// <summary>
        /// Change user notifications in database
        /// </summary>
        /// <param name="emailChk"></param>
        /// <param name="smsChk"></param>
        /// <param name="email"></param>
        /// <param name="phone"></param>
        /// <param name="wakeupDay"></param>
        /// <param name="wakeupEnd"></param>
        /// <param name="timezoneSelect"></param>
        /// <param name="timezoneOffset"></param>
        /// <param name="weekendMode"></param>
        /// <param name="temperature"></param>
        /// <param name="token"></param>
        [HttpPost]
        public JsonResult ChangeNotification(bool emailChk, bool smsChk, string email, string phone,
            string wakeupDay, string wakeupEnd, string timezoneSelect, string timezoneOffset,
            WeekEndMode weekendMode, TemperatureMode temperature, string token)
        {
            GenericResponse responseObj;

            int timeStart = DateTime.Now.TimeOfDay.Seconds;

            try
            {
                string name = oauthFactory.GetOAuthTokenDao().getUser(token).username;

                if (name != null)
                {
                    SendInfo info = new SendInfo()
                    {
                        UserName = name,
                        SendEmail = emailChk,
                        SendSms = smsChk,
                        UserEmail = email,
                        UserPhone = phone,
                        TimeWeekDay = "7:45 PM",
                        TimeWeekEnd = "7:46 PM",
                        TimeZoneValue = timezoneSelect,
                        WeekendMode = weekendMode,
                        Temperature = temperature
                    };

                    if (!string.IsNullOrEmpty(timezoneOffset))
                        info.TimeZoneOffset = 200000m;

                    settingsService.UpdateUserSettings(info);
                }

                responseObj = new GenericResponse()
                {
                    Status = 0,
                    ResponseTime = DateTime.Now.TimeOfDay.Seconds - timeStart,
                    Message = "Settings successfully updated",
                    Data = null,
                };

                return Json(responseObj, JsonRequestBehavior.AllowGet);
            }
            catch (Exception e)
            {
                responseObj = new GenericResponse()
                {
                    Status = 1,
                    ResponseTime = DateTime.Now.TimeOfDay.Milliseconds - timeStart,
                    Message = e.Message,
                    Data = null,
                };
                return Json(responseObj, JsonRequestBehavior.AllowGet);
            }
        }

        /// <summary>
        /// Subscribe user to get push notification
        /// </summary>
        /// <param name="pushCheck"></param>
        /// <param name="deviceToken"></param>
        /// <param name="deviceType"></param>
        /// <param name="accessToken"></param>
        [HttpPost]
        public JsonResult SubscribePushNotification(bool pushCheck, string deviceToken, DeviceType deviceType, string accessToken)
        {
            GenericResponse responseObj;
            int timeStart = DateTime.Now.TimeOfDay.Seconds;

            try
            {
                if (pushCheck)
                    pushService.Subscribe(deviceToken, deviceType, accessToken);
                else
                    pushService.Unsubscribe(deviceToken);

                responseObj = new GenericResponse()
                {
                    Status = 0,
                    ResponseTime = DateTime.Now.TimeOfDay.Seconds - timeStart,
                    Message = "Push notification successfully " + (pushCheck ? "subscribed" : "unsubscribed"),
                    Data = null,
                };

                return Json(responseObj, JsonRequestBehavior.AllowGet);
            }
            catch (Exception e)
            {
                responseObj = new GenericResponse()
                {
                    Status = 1,
                    ResponseTime = DateTime.Now.TimeOfDay.Seconds - timeStart,
                    Message = e.Message,
                    Data = null,
                };

                return Json(responseObj, JsonRequestBehavior.AllowGet);
            }
        }

        /// <summary>
        /// Set new file to database
        /// </summary>
        /// <param name="selectedId"></param>
        /// <param name="selectedName"></param>
        /// <param name="token"></param>
        [HttpPost]
        public JsonResult SaveFile(string selectedId, string selectedName, string token)
        {
            GenericResponse responseObj;
            int timeStart = DateTime.Now.TimeOfDay.Seconds;

            try
            {
                settingsService.SetUserDataFileExt(selectedName, selectedId, token);

                responseObj = new GenericResponse()
                {
                    Status = 0,
                    ResponseTime = DateTime.Now.TimeOfDay.Seconds - timeStart,
                    Message = "File info successfully updated",
                    Data = null,
                };

                return Json(responseObj, JsonRequestBehavior.AllowGet);
            }
            catch (Exception e)
            {
                responseObj = new GenericResponse()
                {
                    Status = 1,
                    ResponseTime = DateTime.Now.TimeOfDay.Seconds - timeStart,
                    Message = e.Message,
                    Data = null,
                };

                return Json(responseObj, JsonRequestBehavior.AllowGet);
            }
        }

        /// <summary>
        /// Change location
        /// </summary>
        /// <param name="city"></param>
        /// <param name="token"></param>
        [HttpPost]
        public JsonResult SaveLocation(string city, string token)
        {
            GenericResponse responseObj;
            int timeStart = DateTime.Now.TimeOfDay.Seconds;

            try
            {
                settingsService.SetUserLocationExt(city, token);

                responseObj = new GenericResponse()
                {
                    Status = 0,
                    ResponseTime = DateTime.Now.TimeOfDay.Seconds - timeStart,
                    Message = "Location successfully updated",
                    Data = null,
                };

                return Json(responseObj, JsonRequestBehavior.AllowGet);
            }
            catch (Exception e)
            {
                responseObj = new GenericResponse()
                {
                    Status = 1,
                    ResponseTime = DateTime.Now.TimeOfDay.Seconds - timeStart,
                    Message = e.Message,
                    Data = null,
                };
                return Json(responseObj, JsonRequestBehavior.AllowGet);
            }
        }


        /// <summary>
        /// Retrieve user settings from database
        /// </summary>
        /// <param name="accessToken"></param>
        /// <param name="expiresIn"></param>
        /// <param name="tokenType"></param>
        /// <param name="scope"></param>
        /// <param name="refreshToken"></param>
        [HttpPost]
        public JsonResult RetrieveUserSettings(string accessToken, string expiresIn, string tokenType, string scope, string refreshToken)
        {
            GenericResponse responseObj;
            int timeStart = DateTime.Now.TimeOfDay.Seconds;

            try
            {
                TokenInfo tokenInfo = new TokenInfo()
                {
                    access_token = accessToken,
                    expires_in = expiresIn,
                    token_type = tokenType,
                    scope = scope,
                    refresh_token = refreshToken
                };

                SendInfo info = settingsService.GetUserSettings(tokenInfo);
                info.LastWeatherUpdate = null;
                info.DeviceTokens = null;

                responseObj = new GenericResponse()
                {
                    Status = 0,
                    ResponseTime = DateTime.Now.TimeOfDay.Seconds - timeStart,
                    Message = "Settings successfully retrieved",
                    Data = info,
                };

                return Json(responseObj, JsonRequestBehavior.AllowGet);
            }
            catch (Exception e)
            {
                responseObj = new GenericResponse()
                {
                    Status = 1,
                    ResponseTime = DateTime.Now.TimeOfDay.Seconds - timeStart,
                    Message = e.Message,
                    Data = null,
                };
                return Json(responseObj, JsonRequestBehavior.AllowGet);
            }
        }

        /// <summary>
        /// Updates expired device token
        /// </summary>
        /// <param name="oldToken"></param>
        /// <param name="newToken"></param>
        /// <param name="accessToken"></param>
        /// <returns></returns>
        [HttpPost]
        public JsonResult UpdateDeviceToken(string oldToken, string newToken, string accessToken)
        {
            GenericResponse responseObj;
            int timeStart = DateTime.Now.TimeOfDay.Seconds;

            try
            {
                pushService.RefreshDeviceToken(oldToken, newToken);

                responseObj = new GenericResponse()
                {
                    Status = 0,
                    ResponseTime = DateTime.Now.TimeOfDay.Seconds - timeStart,
                    Message = string.Format("Old Token {0} successfully updated with new {1} ", oldToken, newToken),
                    Data = null,
                };

                return Json(responseObj, JsonRequestBehavior.AllowGet);
            }
            catch (Exception e)
            {
                responseObj = new GenericResponse()
                {
                    Status = 1,
                    ResponseTime = DateTime.Now.TimeOfDay.Seconds - timeStart,
                    Message = e.Message,
                    Data = null,
                };
                return Json(responseObj, JsonRequestBehavior.AllowGet);
            }
        }
    }
}