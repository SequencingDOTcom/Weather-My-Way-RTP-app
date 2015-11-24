using System;
using Sequencing.WeatherApp.Controllers.WeatherUnderground;
using Sequencing.WeatherApp.Models;

namespace Sequencing.WeatherApp.Controllers
{
    /// <summary>
    /// Produces model for results page
    /// </summary>
    public class RunResultBuilder
    {
        private readonly string userName;
        private TemperatureMode mode;

        public RunResultBuilder(string userName, TemperatureMode mode)
        {
            this.userName = userName;
            this.mode = mode;
        }

        public RunResult Build(string jobId, string jobId2, string city)
        {
            mode = new SendInfoWorker(userName).GetInfo().Temperature ?? TemperatureMode.F;

            var _weatherWorker = new WeatherWorker(mode, userName);

            var _weatherDescripton = _weatherWorker.GetWeatherDescripton(city);

            var _forecastRoot = _weatherWorker.GetForecast10(city);
            var _runResult = new RunResult
                             {
                                 Weather = _weatherDescripton.Item2,
                                 Forecast = _forecastRoot,
                                 CurrentWeather = _weatherDescripton.Item3
                             };
            var _risk = GetRiskValue(jobId, jobId2);
            if (_forecastRoot != null)
            {
                var _alertCode = _forecastRoot.alerts.Count == 0 ? "--" : _forecastRoot.alerts[0].type;
                var _riskDescription = GetRiskDescription(_weatherDescripton.Item1, _alertCode, _risk.Item1, _risk.Item2);
                _runResult.Risk = _riskDescription;
                _runResult.RawRisk = _risk.Item1;
                _runResult.Temperature = mode;
                _runResult.JobDateTime = _risk.Item3;
            }
            return _runResult;
        }

        public Tuple<string,string, DateTime> GetRiskValue(string jobId, string jobId2)
        {
            if (!string.IsNullOrEmpty(jobId))
            {
                var _srv = new BackendServiceFacade(Options.ApiUrl, userName);
                var _appResultsHolder = _srv.GetAppResults(Convert.ToInt64(jobId));
                var _risk = _appResultsHolder.ResultProps.Find(value => value.Name == "RiskDescription").Value;
                _appResultsHolder = _srv.GetAppResults(Convert.ToInt64(jobId2));
                var _itemDataValue = _appResultsHolder.ResultProps.Find(value => value.Name == "result").Value;

                var _vitD = _itemDataValue == "Yes" ? "True" : "False";
                return Tuple.Create(_risk, _vitD, _appResultsHolder.Status.FinishDt ?? DateTime.Now);
            }
            return null;
        }

        public string GetRiskDescription(string condition, string alertCode, string risk, string vitd)
        {
            var _s = new PersonalizedRecommendationsWorker().GetRecommendation(condition, alertCode, risk, vitd);
            if (_s != null)
                return _s;
            return
                "Personalization is not possible due to insufficient genetic data in the selected file. Choose a different genetic data file.";
        }
    }
}