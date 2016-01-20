using System;
using System.Collections.Generic;
using System.Net;
using System.Threading;
using log4net;
using Newtonsoft.Json;
using RestSharp;
using RestSharp.Authenticators;
using Sequencing.WeatherApp.Controllers.OAuth;

namespace Sequencing.WeatherApp.Controllers.AppChain
{
    /// <summary>
    /// SqApiServiceFacade class is responsible for calling SQAPI operations (including app-chain creation, querying statuses and getting results
    /// </summary>
    public class SqApiServiceFacade
    {
        private string url;
        private UserAuthWorker userAuthWorker;

        public SqApiServiceFacade(string url)
        {
            this.url = url;
            userAuthWorker = new UserAuthWorker();
        }

        public SqApiServiceFacade(string apiUrl, string userName)
        {
            url = apiUrl;
            userAuthWorker = new UserAuthWorker(userName);
        }

        private RestRequest CreateRq(string opName, Method method)
        {
            var _restRequest = new RestRequest(opName, method);
            return _restRequest;
        }

        private RestClient CreateClient()
        {
            var _restClient = new RestClient(url);
            var _userInfo = userAuthWorker.GetCurrent();
            _restClient.Authenticator = new OAuth2AuthorizationRequestHeaderAuthenticator(_userInfo.AuthToken);
            return _restClient;
        }

        /// <summary>
        /// Returns results of executed app chain
        /// </summary>
        /// <param name="idJob">app chain job id</param>
        /// <returns></returns>
        public AppResultsHolder GetAppChainResults(long idJob)
        {
            var _restClient = CreateClient();
            var _restRequest = CreateRq("GetAppResults", Method.GET);
            _restRequest.AddParameter("idJob", idJob, ParameterType.QueryString);
            var _restResponse = RunRq(_restClient, _restRequest);
            LogManager.GetLogger(GetType()).DebugFormat("Called GetAppResults:{0},{1}", idJob, _restResponse.Content);
            return JsonConvert.DeserializeObject<AppResultsHolder>(_restResponse.Content);
        }

        /// <summary>
        /// Sends user onsite notification
        /// </summary>
        /// <param name="msg">message to user</param>
        public void SendUserNotification(string msg)
        {
            var _restClient = CreateClient();
            var _restRequest = CreateRq("UserAlertNotify", Method.POST);
            _restRequest.AddParameter(new Parameter
            {
                Name = "application/json",
                Value = JsonConvert.SerializeObject(new UserNotification
                                                    {
                                                        PlainTextBody = msg,
                                                        NotificationUrl = Options.BaseSiteUrl,
                                                        SendOnSite = true
                                                    }),
                Type = ParameterType.RequestBody
            });
            var _restResponse = RunRq(_restClient, _restRequest);
            LogManager.GetLogger(GetType()).DebugFormat("SendUserNotification:{0}", _restResponse.Content);
        }

        private class UserNotification
        {
            public bool SendOnSite { get; set; }
            public string NotificationUrl { get; set; }
            public string PlainTextBody { get; set; }
        }

        public const string MELANOMA_APP_CHAIN_ID = "Chain9";
        public const string VITD_APP_CHAIN_ID = "Chain88";


        /// <summary>
        /// Runs requests, is executed several times in case of error - request is attempted with refreshed auth data
        /// </summary>
        /// <param name="_restClient"></param>
        /// <param name="_restRequest"></param>
        /// <returns></returns>
        private  IRestResponse RunRq(RestClient _restClient, RestRequest _restRequest)
        {
            IRestResponse _restResponse = null;
            for (int _idx = 0; _idx < 5; _idx++)
            {
                _restResponse = _restClient.Execute(_restRequest);
                if (_restResponse.StatusCode != HttpStatusCode.OK)
                {
                    var _userInfo = userAuthWorker.GetCurrent();
                    var _newInfo =
                        new AuthWorker(Options.OAuthUrl, Options.OAuthRedirectUrl, Options.OAuthSecret,
                            Options.OAuthAppId).RefreshToken(_userInfo.RefreshToken);
                    if (!_newInfo.Success)
                        throw new Exception("Error while token refresh:" + _userInfo.RefreshToken+"," + _newInfo.ErrorMessage);
                    _userInfo.AuthToken = _newInfo.Token.access_token;
                    var _updateToken = userAuthWorker.UpdateToken(_userInfo);
                    _restClient.Authenticator = new OAuth2AuthorizationRequestHeaderAuthenticator(_updateToken.AuthToken);
                    _restRequest.Parameters.RemoveAll(parameter => parameter.Name == "Authorization");
                    _restResponse = _restClient.Execute(_restRequest);
                }
                if (_restResponse.StatusCode == HttpStatusCode.OK)
                    return _restResponse;
                Thread.Sleep(5*1000);
            }
            return _restResponse;
        }

        /// <summary>
        /// Checks executing app chain status
        /// </summary>
        /// <param name="idJob">app chain job id</param>
        /// <returns>Status of app-chain, Executing/Completed/Pending</returns>
        public string CheckAppChainStatus(long idJob)
        {
            var _restClient = CreateClient();
            var _restRequest = CreateRq("CheckAppStatus", Method.GET);
            _restRequest.AddParameter("idJob", idJob, ParameterType.QueryString);
            var _restResponse = RunRq(_restClient, _restRequest);
            return _restResponse.Content.Replace("\"", "");
        }

        /// <summary>
        /// Starts app-chain
        /// </summary>
        /// <param name="appCode">code of app-chain</param>
        /// <param name="pars">app-chain parameters</param>
        /// <returns></returns>
        public StartAppRs StartAppChain(string appCode, Dictionary<string, string> pars)
        {
            var _restClient = CreateClient();
            var _restRequest = CreateRq("StartApp", Method.POST);
            var _appStartParams = new AppStartParams
                                  {
                                      AppCode = appCode,
                                      Pars = new List<NewJobParameter>()
                                  };
            foreach (var _par in pars)
                _appStartParams.Pars.Add(new NewJobParameter(_par.Key, _par.Value));
            _restRequest.AddParameter(new Parameter
                                      {
                                          Name = "application/json",
                                          Value = JsonConvert.SerializeObject(_appStartParams),
                                          Type = ParameterType.RequestBody
                                      });
            var _restResponse = RunRq(_restClient, _restRequest);
            return JsonConvert.DeserializeObject<StartAppRs>(_restResponse.Content);
        }

        /// <summary>
        /// App-chain start parameters
        /// </summary>
        public class AppStartParams
        {
            public string AppCode { get; set; }
            public List<NewJobParameter> Pars { get; set; }
        }

        /// <summary>
        /// Server response on creating the app-chain job
        /// </summary>
        public class StartAppRs
        {
            public long jobId { get; set; }
            public bool status { get; set; }
        }
        
        /// <summary>
        /// Contains completed app-chain result values
        /// </summary>
        public class AppResultsHolder
        {
            private readonly List<ItemDataValue> resultProps = new List<ItemDataValue>();

            public List<ItemDataValue> ResultProps
            {
                get { return resultProps; }
            }

            public AppStatus Status { get; set; }
        }

        /// <summary>
        /// Data-holder for executing app chain job
        /// </summary>
        public class AppStatus
        {
            /// <summary>
            /// AppChain job ID
            /// </summary>
            public long IdJob { get; set; }

            /// <summary>
            /// Current job status, possible values are:  Pending,Running,Completed
            /// </summary>
            public string Status { get; set; }
            
            /// <summary>
            /// Identifies whether job has completed succesfully, has only meaning in case of Completed job
            /// </summary>
            public bool? CompletedSuccesfully { get; set; }
            
            /// <summary>
            /// App chain job finish time
            /// </summary>
            public DateTime? FinishDt { get; set; }
        }

        /// <summary>
        /// Item data value from the app chain results
        /// </summary>
        public class ItemDataValue
        {
            /// <summary>
            /// Represents current item name
            /// </summary>
            public string Name { get; set; }
            /// <summary>
            /// Additional title value-optional
            /// </summary>
            public string Title { get; set; }
            /// <summary>
            /// Additional sub-title value, optional
            /// </summary>
            public string SubTitle { get; set; }
            /// <summary>
            /// Description string, optional
            /// </summary>
            public string Description { get; set; }
            /// <summary>
            /// Item type value, can be of the following:   PlainText,HtmlText,ImageUrl,VideoUrl,HTML5,Pdf,ViewTable,Chart,DataFile,SVG 
            /// </summary>
            public string Type { get; set; }
            /// <summary>
            /// Additional sub-type value, optional, might be specified for certain types only, like ViewTable for example
            /// </summary>
            public string SubType { get; set; }
            /// <summary>
            /// Item value setting
            /// </summary>
            public string Value { get; set; }
        }

        /// <summary>
        /// App chain parameter
        /// </summary>
        public class NewJobParameter
        {
            public NewJobParameter(string name, string value)
            {
                Name = name;
                Value = value;
            }

            public NewJobParameter(string value)
            {
                Value = value;
            }

            public NewJobParameter(long? val)
            {
                ValueLong = val;
            }


            public NewJobParameter()
            {
            }

            public string Name { get; set; }
            public string Value { get; set; }
            public long? ValueLong { get; set; }
        }
    }
}