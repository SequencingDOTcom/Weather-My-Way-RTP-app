using System;
using Sequencing.WeatherApp.Controllers.WeatherUnderground;
using Sequencing.WeatherApp.Models;
using Sequencing.WeatherApp.Controllers.DaoLayer;

namespace Sequencing.WeatherApp.Controllers.AppChain
{
    /// <summary>
    /// Produces model for results page
    /// </summary>
    public class PersonalizedForecastResultBuilder
    {
        private readonly string userName;
        private TemperatureMode mode;

        ISettingService service = new UserSettingService();

        public PersonalizedForecastResultBuilder(string userName, TemperatureMode mode)
        {
            this.userName = userName;
            this.mode = mode;
        }

        /// <summary>
        /// Builds forecast page model for given app-chain job IDs and location
        /// </summary>
        /// <param name="jobId"></param>
        /// <param name="jobId2"></param>
        /// <param name="city"></param>
        /// <returns></returns>
        public RunResult Build(string jobId, string jobId2, string city)
        {
            mode = service.GetInfo(userName).Temperature ?? TemperatureMode.F;

            var _weatherWorker = new WeatherWorker(userName);

            var _forecastRoot = _weatherWorker.GetForecast10(city);
            var _runResult = new RunResult
                             {
                                 Weather =  _forecastRoot.current_observation.weather + " " +
                                             (mode == TemperatureMode.F
                                                 ? _forecastRoot.current_observation.temp_f + "F"
                                                 : _forecastRoot.current_observation.temp_c + "C"),
                                 Forecast = _forecastRoot,
                                 CurrentWeather = _forecastRoot.current_observation
                             };
            var _appChainResults = GetAppChainResultingRisks(jobId, jobId2);
            if (_forecastRoot != null)
            {
                var _alertCode = _forecastRoot.alerts.Count == 0 ? "--" : _forecastRoot.alerts[0].type;
                var _riskDescription = GetPersonalizedRiskDescription(_forecastRoot.forecast.simpleforecast.forecastday[0].conditions, 
                    _alertCode, _appChainResults);
                _runResult.Risk = _riskDescription;
                _runResult.RawRisk = _appChainResults.MelanomaAppChainResult.ToString();
                _runResult.Temperature = mode;
                _runResult.JobDateTime = _appChainResults.AppChainRunDt;
            }
            return _runResult;
        }

        /// <summary>
        /// Retrieves app-chain results for given app-chain jobs IDs
        /// </summary>
        /// <param name="acJobIdMelanoma"></param>
        /// <param name="acJobIdVitD"></param>
        /// <returns></returns>
        public AppChainResults GetAppChainResultingRisks(string acJobIdMelanoma, string acJobIdVitD)
        {
            if (!string.IsNullOrEmpty(acJobIdMelanoma))
            {
                var _srv = new SqApiServiceFacade(Options.ApiUrl, userName);
                var _acHolder = _srv.GetAppChainResults(Convert.ToInt64(acJobIdMelanoma));
                var _risk = _acHolder.ResultProps.Find(value => value.Name == "RiskDescription").Value;
                _acHolder = _srv.GetAppChainResults(Convert.ToInt64(acJobIdVitD));
                var _vitDResult = _acHolder.ResultProps.Find(value => value.Name == "result").Value;

                var _melanomaACRisk =
                    (RegularQualitativeResultType) Enum.Parse(typeof (RegularQualitativeResultType), _risk);
                return new AppChainResults
                       {
                           MelanomaAppChainResult = _melanomaACRisk,
                           AppChainRunDt = _acHolder.Status.FinishDt ?? DateTime.Now,
                           VitDAppChainResult = _vitDResult == "Yes"
                       };
            }
            return null;
        }

        /// <summary>
        /// Returns personalized recommendation for given weather/alert/appChain results
        /// </summary>
        /// <param name="weatherCondition"></param>
        /// <param name="weatherAlertCode"></param>
        /// <param name="acr"></param>
        /// <returns></returns>
        public string GetPersonalizedRiskDescription(string weatherCondition, string weatherAlertCode, AppChainResults acr)
        {
            var _s = new PersonalizedRecommendationsWorker().GetRecommendation(weatherCondition, weatherAlertCode, acr);
            if (_s != null)
                return _s;
            return
                "Personalization is not possible due to insufficient genetic data in the selected file. Choose a different genetic data file.";
        }
    }
}