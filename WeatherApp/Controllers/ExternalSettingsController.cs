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
        OAuthTokenDaoFactory oauthFactoryDao = new OAuthTokenDaoFactory();
        ISettingService settingService = new UserSettingService();

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
        public JsonResult ChangeNotification(SettingsDto settings)
        {
            GenericResponse responseObj = null;
            string name = null;
            int timeStart = DateTime.Now.TimeOfDay.Seconds;

            try
            {
                name = oauthFactoryDao.GetOAuthTokenDao().getUser(settings.token).username;

                if (name != null)
                {
                    SendInfo info = new SendInfo()
                    {
                        UserName = name,
                        SendEmail = settings.emailChk,
                        SendSms = settings.smsChk,
                        UserEmail = settings.email,
                        UserPhone = settings.phone,
                        TimeWeekDay = settings.wakeupDay,
                        TimeWeekEnd = settings.wakeupEnd,
                        TimeZoneValue = settings.timezoneSelect,
                        WeekendMode = settings.weekendMode,
                        Temperature = settings.temperature,
                        CountryCode = settings.countryCode,
                    };

                    if (!string.IsNullOrEmpty(settings.timezoneOffset))
                        info.TimeZoneOffset = settingService.ParseTimeZoneOffset(settings.timezoneOffset);

                    settingService.UpdateUserSettings(info);
                }

                responseObj = new GenericResponse()
                {
                    Status = 0,
                    ResponseTime = DateTime.Now.TimeOfDay.Seconds - timeStart,
                    Message = "Settings successfully updated for user: " + name,
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
                    Message = string.Format("Error while notification settings for user: {0}. Message is: {1}", name, e.Message),
                    Data = null,
                };

                ResponseLogging(responseObj);
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
        public JsonResult SubscribePushNotification(bool pushCheck, string deviceToken,
            DeviceType deviceType, string accessToken)
        {
            GenericResponse responseObj = null;
            int timeStart = DateTime.Now.TimeOfDay.Seconds;
            string userName = null;
            try
            {
                userName = new AuthWorker(Options.OAuthUrl, Options.OAuthRedirectUrl, Options.OAuthSecret,
                        Options.OAuthAppId).GetUserInfo(accessToken).username;

                if (pushCheck)
                    pushService.Subscribe(deviceToken, deviceType, accessToken);
                else
                {
                    
                    if (userName != null)
                    {
                        var userId = factory.GetDeviceTokenDao().GetUserIdByName(userName);
                        pushService.Unsubscribe(deviceToken, userId);
                    }
                    else
                        throw new Sequencing.WeatherApp.Controllers.DaoLayer.ApplicationException(string.Format("Invalid access token {0}", accessToken));
                }

                responseObj = new GenericResponse()
                {
                    Status = 0,
                    ResponseTime = DateTime.Now.TimeOfDay.Seconds - timeStart,
                    Message = string.Format("Push notification successfully {0} for user: {1} ", pushCheck ? "subscribed" : "unsubscribed" , userName),
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
                    Message = string.Format("Error subscribing  push notification for user: {0}. Message is: {1}", userName, e.Message),
                    Data = null,
                };

                ResponseLogging(responseObj);
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
            GenericResponse responseObj = null;
            int timeStart = DateTime.Now.TimeOfDay.Seconds;

            try
            {
                settingService.SetUserDataFileExt(selectedName, selectedId, token);

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
                ResponseLogging(responseObj);
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
            GenericResponse responseObj = null;
            int timeStart = DateTime.Now.TimeOfDay.Seconds;

            try
            {
                settingService.SetUserLocationExt(city, token);

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
                ResponseLogging(responseObj);
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
        /// <param name="oldDeviceToken"></param>
        /// <param name="newDeviceToken"></param>
        /// <param name="sendPush"></param>
        /// <param name="deviceType"></param>
        /// <returns></returns>
        [HttpPost]
        public JsonResult RetrieveUserSettings(string accessToken, string expiresIn, string tokenType, string scope, string refreshToken, string oldDeviceToken, 
            string newDeviceToken, bool sendPush, DeviceType deviceType)
        {

            GenericResponse responseObj = null;
            int timeStart = DateTime.Now.TimeOfDay.Seconds;
            SendInfo info = null;
            string userName = null;

            try
            {
                userName = new AuthWorker(Options.OAuthUrl, Options.OAuthRedirectUrl, Options.OAuthSecret,
                        Options.OAuthAppId).GetUserInfo(accessToken).username;

                info = settingService.RetrieveSettings(accessToken, expiresIn, tokenType, scope, refreshToken);

                string message = settingService.DeviceTokenSetting(oldDeviceToken, newDeviceToken, sendPush, deviceType, accessToken, info.Id);

                responseObj = new GenericResponse()
                {
                    Status = 0,
                    ResponseTime = DateTime.Now.TimeOfDay.Seconds - timeStart,
                    Message = message,
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
                    Message = string.Format("Error retrieving  settings for user: {0}. Message is: {1}", userName, e.Message),
                    Data = info,
                };

                ResponseLogging(responseObj);
                return Json(responseObj, JsonRequestBehavior.AllowGet);
            }
        }

        public void ResponseLogging(GenericResponse responseObj)
        {
            log.ErrorFormat(string.Format("Response object: [Status = {0}, ResponseTime = {1}, Message = {2}, Data = {3}]", responseObj.Status,
                responseObj.ResponseTime, responseObj.Message, responseObj.Data));
        }
    }
}