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

namespace Sequencing.WeatherApp.Controllers
{
    public class ExternalForecastRetrieveController : Controller
    {
        [HttpPost]
        public JsonResult GetForecast(ForecastRetrieveDTO forecastDTO)
        {
            GenericResponse responseObj = null;
            int timeStart = DateTime.Now.TimeOfDay.Seconds;
            try
            {
                string userName = new AuthWorker(Options.OAuthUrl, Options.OAuthRedirectUrl, Options.OAuthSecret,
                        Options.OAuthAppId).GetUserInfo(forecastDTO.authToken).username;
                if(userName == null) throw new Sequencing.WeatherApp.Controllers.DaoLayer.ApplicationException(string.Format("Invalid access token {0}", forecastDTO.authToken));

                AppChainResults acr = new AppChainResults
                {
                    MelanomaAppChainResult = forecastDTO.melanomaRisk,
                    VitDAppChainResult = forecastDTO.vitaminD
                };

                var _s = new PersonalizedRecommendationsWorker().GetRecommendation(forecastDTO.forecastRequest, acr, userName);

                responseObj = new GenericResponse()
                {
                    Status = 0,
                    ResponseTime = DateTime.Now.TimeOfDay.Seconds - timeStart,
                    Message = "Genetically tailored forecast successfully retrieved",
                    Data = _s,
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
                    Data = "Personalization is not possible due to insufficient genetic data in the selected file. Choose a different genetic data file.",
                };

                ExternalSettingsController.ResponseLogging(responseObj);
                return Json(responseObj, JsonRequestBehavior.AllowGet);
            }
        }
    }
}