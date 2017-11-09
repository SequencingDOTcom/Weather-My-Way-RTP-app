using log4net;
using Sequencing.WeatherApp.Controllers;
using Sequencing.WeatherApp.Controllers.AppChain;
using Sequencing.WeatherApp.Controllers.DaoLayer;
using Sequencing.WeatherApp.Controllers.OAuth;
using Sequencing.WeatherApp.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;
using Newtonsoft.Json;

namespace Sequencing.WeatherApp.Controllers
{
    public class ExternalForecastRetrieveController : Controller
    {
        public static ILog log = LogManager.GetLogger(typeof(ExternalForecastRetrieveController));

        [HttpPost]
        public JsonResult GetForecast(ForecastRetrieveDTO forecastDTO)
        {
            log.Info(string.Format("Request: {0}", JsonConvert.SerializeObject(forecastDTO)));

            GenericResponse responseObj = null;
            int timeStart = DateTime.Now.TimeOfDay.Seconds;
            string userName = "";
            try
            {
                userName = new AuthWorker(Options.OAuthUrl, Options.OAuthRedirectUrl, Options.OAuthSecret,
                        Options.OAuthAppId).GetUserInfo(forecastDTO.authToken).username;
                if(userName == null) throw new Sequencing.WeatherApp.Controllers.DaoLayer.ApplicationException(string.Format("Invalid access token {0}", forecastDTO.authToken));

                AppChainResults acr = new AppChainResults
                {
                    MelanomaAppChainResult = forecastDTO.melanomaRisk,
                    VitDAppChainResult = forecastDTO.vitaminD
                };

                var _s = new PersonalizedRecommendationsWorker().GetRecommendation(forecastDTO.forecastRequest, acr, userName, forecastDTO.appId);

                responseObj = new GenericResponse()
                {
                    Status = 0,
                    ResponseTime = DateTime.Now.TimeOfDay.Seconds - timeStart,
                    Message = "Genetically tailored forecast successfully retrieved",
                    Data = _s,
                };

                log.Info(string.Format("Response: {0}", JsonConvert.SerializeObject(responseObj)));
                return Json(responseObj, JsonRequestBehavior.AllowGet);
            }
            catch (Exception e)
            {
                responseObj = new GenericResponse()
                {
                    Status = 1,
                    ResponseTime = DateTime.Now.TimeOfDay.Milliseconds - timeStart,
                    Message = e.Message,
                    Data = null
                };

                log.Error(string.Format("Error getting GT forecast: username - {0}", userName));
                log.Error(string.Format("Error is: {0}", e));
                return Json(responseObj, JsonRequestBehavior.AllowGet);
            }
        }
    }
}