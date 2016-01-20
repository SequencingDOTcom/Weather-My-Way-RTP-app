using System.Collections.Generic;
using System.IO;
using CsvHelper;
using CsvHelper.Configuration;

namespace Sequencing.WeatherApp.Controllers.AppChain
{
    /// <summary>
    /// Produces personalized recommendations
    /// </summary>
    public class PersonalizedRecommendationsWorker
    {
        private readonly List<PersonalRecommendation> items = new List<PersonalRecommendation>();

        /// <summary>
        /// Loads PR data from csv file. Sample file is included into solution and named as recs.csv
        /// </summary>
        public PersonalizedRecommendationsWorker()
        {
            string[] _firstLine = null;
            using (var _file = File.OpenRead(Options.RecommendationsPath))
            using (var _sr = new StreamReader(_file))
            using (var _csvReader = new CsvParser(_sr, new CsvConfiguration{HasHeaderRecord = false}))
            {
                string[] _fields;
                do
                {
                    _fields = _csvReader.Read();
                    
                    if (_firstLine == null)
                        _firstLine = _fields;
                    else if (_fields != null)
                    {
                        for (int _idx = 1; _idx < 13; _idx++)
                        {
                            var _split = _firstLine[_idx].Split('-');
                            var _personalRecommendation = new PersonalRecommendation
                            {
                                Recommendation = _fields[_idx],
                                Risk = _split[0],
                                VitD = _split[1],
                                WeatherCondition = _fields[0]
                            };
                            items.Add(_personalRecommendation);
                        }
                    }    
                } while (_fields != null);
            }
        }
            
        /// <summary>
        /// Returns PR for given weather/alert/app-chains. First scans for alerts, then for regular weather conditions.
        /// </summary>
        /// <param name="weatherCondition"></param>
        /// <param name="alert"></param>
        /// <param name="acr"></param>
        /// <returns></returns>
        public string GetRecommendation(string weatherCondition, string alert, AppChainResults acr)
        {
            var _melanomaRisk = acr.MelanomaAppChainResult.ToString();
            var _vitDRisk = acr.VitDAppChainResult ? "True" : "False";
            var _rec = GetRecommendationImpl(alert, _melanomaRisk, _vitDRisk);
            if (_rec != null)
                return _rec;
            return GetRecommendationImpl(weatherCondition, _melanomaRisk, _vitDRisk);
        }

        /// <summary>
        /// Exact implementation for searching for PR on given weather/melanoma risk/vitd status.
        /// </summary>
        /// <param name="weatherCondition"></param>
        /// <param name="risk"></param>
        /// <param name="vitD"></param>
        /// <returns></returns>
        private string GetRecommendationImpl(string weatherCondition, string risk, string vitD)
        {
            foreach (var _item in items)
            {
                if (CompareLower(_item.WeatherCondition, weatherCondition) &&
                    CompareLower(_item.Risk, risk) &&
                    CompareLower(_item.VitD, vitD))
                    return _item.Recommendation;
            }
            return null;
        }

        private static bool CompareLower(string s1, string s2)
        {
            if (s1 != null && s2 != null)
                return s1.ToLower() == s2.ToLower();
            return false;
        }
    }
}