using System.Collections.Generic;
using System.IO;
using CsvHelper;
using CsvHelper.Configuration;
using Sequencing.WeatherApp.Controllers.DaoLayer;
using Sequencing.WeatherApp.Models;
using System.Collections;
using System;
using System.Linq;
using Newtonsoft.Json;
using Sequencing.WeatherApp.Controllers.WeatherUnderground;
using log4net;
using System.Data.SqlClient;
using System.Data;
using System.Configuration;
using Newtonsoft.Json.Serialization;

namespace Sequencing.WeatherApp.Controllers.AppChain
{
    /// <summary>
    /// Produces personalized recommendations
    /// </summary>
    /// 
    public class PersonalizedRecommendationsWorker
    {

        private MSSQLDaoFactory factory = new MSSQLDaoFactory();
        public ILog logger = LogManager.GetLogger(typeof(PersonalizedRecommendationsWorker));


        /// <summary>
        /// Returns PR for given weather/alert/app-chains. First scans for alerts, then for regular weather conditions.
        /// </summary>
        /// <param name="weatherCondition"></param>
        /// <param name="alert"></param>
        /// <param name="acr"></param>
        /// <returns></returns>
        public List<ForecastResponse> GetRecommendation(ForecastRequest [] request, AppChainResults acr, string userName, int appId)
        {
            var _melanomaRisk = acr.MelanomaAppChainResult.ToString();
            var _vitDRisk = acr.VitDAppChainResult;
            var _rec = GetRecommendationImpl(request, _melanomaRisk, _vitDRisk, userName, appId);
            if (_rec != null)
                return _rec;
            return GetRecommendationImpl(request, _melanomaRisk, _vitDRisk, userName, appId);
        }

        /// <summary>
        /// Exact implementation for searching for PR on given weather/melanoma risk/vitd status.
        /// </summary>
        /// <param name="weatherCondition"></param>
        /// <param name="risk"></param>
        /// <param name="vitD"></param>
        /// <returns></returns>
        private List<ForecastResponse> GetRecommendationImpl(ForecastRequest [] request, string risk, bool vitD, string userName, int appId)
        {
            List<ForecastResponse> list = new List<ForecastResponse>();

            using (WeatherAppDbEntities db = new WeatherAppDbEntities())
            {
                var vitDId = db.VitaminDs.Where(con => con.Type == vitD).Select(info => info.Id).FirstOrDefault();
                var melanomaRiskId = db.MelanomaRisks.Where(con => con.Type == risk).Select(info => info.Id).FirstOrDefault();
                var userId = db.SendInfo.Where(con => con.UserName == userName).Select(info => info.Id).FirstOrDefault();

                var appTypeId =
                    db.ApplicationNames.Where(app => app.Id == appId).Select(app => app.Id).FirstOrDefault();
                if (appId == 0 || appTypeId == 0)
                   appId = Options.ApplicationName;

                foreach (ForecastRequest req in request)
                {
                    var condId = db.Conditions.Where(con => con.WeatherCond == req.weather).Select(info => info.Id).FirstOrDefault();
                    if (condId == 0)
                        return null;
                    try
                    {
                        list.Add(new ForecastResponse
                        {
                            gtForecast =
                                factory.GetSendForecastDao()
                                    .StorageProcetureCalling(req.date, condId, vitDId, melanomaRiskId, userId, appId),
                            date = req.date.ToString()
                        });
                    }
                    catch (Exception ex)
                    {
                        list.Add(new ForecastResponse
                        {
                            gtForecast =
                                "Personalization is not possible due to insufficient genetic data in the selected file. Choose a different genetic data file.",
                            date = req.date.ToString()
                        });
                    }
                   
                }

                var serializer = new System.Web.Script.Serialization.JavaScriptSerializer();
                logger.Info(string.Format("Inputs: [ForecastRequest = {0}, Risk = {1}, vitaminD = {2} ] for user {3}", serializer.Serialize(request), risk , vitD, userName));

                logger.Info(string.Format("Outputs: GT forecast [{0}]", string.Join(",", serializer.Serialize(list) )));

                return list;
            }
        }

        private static bool CompareLower(string s1, string s2)
        {
            if (s1 != null && s2 != null)
                return s1.ToLower() == s2.ToLower();
            return false;
        }
    }
}