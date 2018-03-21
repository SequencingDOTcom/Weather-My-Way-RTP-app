using System;
using System.Collections.Generic;
using System.Net;
using System.Web;
using System.Web.Mvc;
using System.Web.Security;
using Sequencing.WeatherApp.Controllers.AppChain;
using Sequencing.WeatherApp.Controllers.OAuth;
using Sequencing.WeatherApp.Controllers.WeatherUnderground;
using Sequencing.WeatherApp.Models;
using Sequencing.WeatherApp.Controllers.DaoLayer;
using Newtonsoft.Json;
using Sequencing.WeatherApp.Controllers;
using log4net;
using Sequencing.WeatherApp.Controllers.PushNotification;

namespace Sequencing.WeatherApp.Controllers
{

    public class DefaultController : ControllerBase
    {
        private readonly AuthWorker authWorker = new AuthWorker(Options.OAuthUrl, Options.OAuthRedirectUrl, Options.OAuthSecret, Options.OAuthAppId);
        public ILog log = LogManager.GetLogger(typeof(DefaultController));
        ISettingService settingService = new UserSettingService();
        public static LocationVerifier.RootObject rootObj;

        /// <summary>
        /// Landing page
        /// </summary>
        /// <returns></returns>
        [AllowAnonymous]
        public ActionResult Startup()
        {
            if (Context.IsAuthenticated)
            {
                var _urlReferrer = Request.UrlReferrer;
                if (_urlReferrer == null || _urlReferrer.Host != Request.Url.Host)
                {
                    return RedirectToAction("StartJobSequence");
                }
            }
            return View(new CommonData());
        }

        /// <summary>
        /// Results shortcut - if user has selected dataFile/city then new app chains are started automatically.
        /// </summary>
        /// <returns></returns>
        [Authorize]
        public ActionResult GoToResults()
        {
            if (!string.IsNullOrEmpty(Context.DataFileId) && !string.IsNullOrEmpty(Context.City))
                return RedirectToAction("StartJob", new { selectedId = Context.DataFileId });
            return RedirectToAction("Startup");
        }


        /// <summary>
        /// OAuth workflow supporting callback action
        /// </summary>
        /// <param name="code"></param>
        /// <returns></returns>
        [AllowAnonymous]
        public ActionResult AuthCallback(string code)
        {
            if (code != null)
            {
                var _authInfo = authWorker.GetAuthInfo(code);
                if (_authInfo.Success)
                {
                    var _id = new UserAuthWorker().CreateNewUserToken(_authInfo.Token);
                    var _authTicket = new FormsAuthenticationTicket(1, _id.UserName, DateTime.Now, DateTime.Now.AddDays(15),
                        true, _id.Id.ToString());
                    var encTicket = FormsAuthentication.Encrypt(_authTicket);
                    var faCookie = new HttpCookie(FormsAuthentication.FormsCookieName, encTicket);

                    Response.Cookies.Add(faCookie);

                    return RedirectToAction("Startup");
                }
                return new ContentResult { Content = "Error while retrieving access token:" + _authInfo.ErrorMessage };
            }
            return new ContentResult { Content = "User cancelled the auth sequence" };
        }

        /// <summary>
        /// About page
        /// </summary>
        /// <returns></returns>
        [AllowAnonymous]
        public ActionResult About()
        {
            return View(new CommonData());
        }

        /// <summary>
        /// Initiates main app sequence
        /// </summary>
        /// <returns></returns>
        [Authorize]
        public ActionResult StartJobSequence()
        {
            if (!string.IsNullOrEmpty(Context.City) && !string.IsNullOrEmpty(Context.DataFileId))
                return RedirectToAction("CheckApp");
            return RedirectToAction("Location");
        }

        /// <summary>
        /// Location selection
        /// </summary>
        /// <returns></returns>
        [Authorize]
        public ActionResult Location()
        {
            return View(new CommonData());
        }

        /// <summary>
        /// File selection
        /// </summary>
        /// <returns></returns>
        [Authorize]
        public ActionResult SelectFile()
        {
            return View("SelectFile", new CommonData());
        }

        /// <summary>
        /// Checks appchains completions. Is used from CheckApp page through AJAX call
        /// </summary>
        /// <param name="jobId"></param>
        /// <param name="jobId2"></param>
        /// <returns></returns>
        [Authorize]
        public bool CheckAppCompletion(string jobId, string jobId2)
        {
            var _srv = new SqApiServiceFacade(Options.ApiUrl);
            var _appStatus = _srv.CheckAppChainStatus(Convert.ToInt64(jobId));
            var _appStatus2 = _srv.CheckAppChainStatus(Convert.ToInt64(jobId2));
            if (_appStatus == "Completed" && _appStatus2 == "Completed")
                return true;
            return false;
        }

        /// <summary>
        /// CheckApp page
        /// </summary>
        /// <param name="jobId"></param>
        /// <param name="jobId2"></param>
        /// <returns></returns>
        [Authorize]
        public ActionResult CheckApp()
        {
            return View(new CheckAppData { selectedId = Context.DataFileId });
        }

        /// <summary>
        /// Starts app chains
        /// </summary>
        /// <param name="selectedId"></param>
        /// <returns></returns>
        [Authorize]
        public JsonResult StartJob(string selectedId)
        {
            var _srv = new SqApiServiceFacade(Options.ApiUrl);

            var appChainsParms = new Dictionary<string, string>() { { SqApiServiceFacade.MELANOMA_APP_CHAIN_ID, selectedId }, { SqApiServiceFacade.VITD_APP_CHAIN_ID, selectedId } };
            var appChainsResult = _srv.StartAppChains(appChainsParms);
            return Json(JsonConvert.SerializeObject(new CheckAppData()
            {
                selectedId = Context.DataFileId,
                melanomaRisk = appChainsResult[SqApiServiceFacade.MELANOMA_APP_CHAIN_ID],
                vitD = appChainsResult[SqApiServiceFacade.VITD_APP_CHAIN_ID]
            }), JsonRequestBehavior.AllowGet);
        }

        /// <summary>
        /// Original results page, simply redirects to results implementation supplying additional timestamp parameter
        /// </summary>
        /// <param name="jobId"></param>
        /// <param name="jobId2"></param>
        /// <returns></returns>
        [Authorize]
        public ActionResult ResultsOriginal(string jobId, string jobId2)
        {
            return RedirectToAction("Results", new { jobId, jobId2, timestamp = DateTime.Now.Ticks });
        }
        public const int MINUTES_FOR_RESULTS_USER_REFRESH = 2;


        /// <summary>
        /// Main results page (dashboard)
        /// </summary>
        /// <param name="jobId"></param>
        /// <param name="jobId2"></param>
        /// <param name="timestamp"></param>
        /// <returns></returns>
        [Authorize]
        public ActionResult Results(string melanomaRisk, string vitD, long? timestamp)
        {
            if (melanomaRisk == null)
                return RedirectToAction("CheckApp");

            var _isAuthenticated = User.Identity.IsAuthenticated;
            var _userName = User.Identity.Name;
            var _runResult = new PersonalizedForecastResultBuilder(_userName, TemperatureMode.F).Build(melanomaRisk, vitD, Context.City);
            Context.City = WeatherWorker.ConvertFromIDToName(Context.City);
            ViewBag.ShowEmail = _isAuthenticated;
            ViewBag.City = Context.City;
            ViewBag.LastJobId = 405762;
            return View(_runResult);
        }

        /// <summary>
        /// Initiates oauth sequence
        /// </summary>
        /// <returns></returns>
        [AllowAnonymous]
        public ActionResult StartAuth()
        {
            return Redirect(authWorker.GetAuthUrl());
        }

        /// <summary>
        /// Logs out user
        /// </summary>
        /// <returns></returns>
        public ActionResult Logout()
        {
            FormsAuthentication.SignOut();
            return RedirectToAction("Startup");
        }

        public const int MINUTES_FOR_RESULTS_REFRESH = 60;

        /// <summary>
        /// Checks if dashboard page shall be renewed
        /// </summary>
        /// <param name="jobdt"></param>
        /// <returns></returns>
        public bool CheckForJobRefresh(DateTime jobdt)
        {
            if (DateTime.Now.Subtract(jobdt).TotalMinutes > MINUTES_FOR_RESULTS_REFRESH)
                return true;
            return false;
        }


        /// <summary>
        /// Verifies location, routes requests to WU, is used from location page.
        /// </summary>
        /// <param name="city"></param>
        /// <returns></returns>

        [HttpPost]
        public JsonResult FillLocationBox(string city)
        {
            using (var _wb = new WebClient())
            {
                var _res = _wb.DownloadString("http://autocomplete.wunderground.com/aq?format=JSON&query=" + city);
                rootObj = JsonConvert.DeserializeObject<LocationVerifier.RootObject>(_res);
                List<LocationVerifier.RootObject.RESULT> result = new List<LocationVerifier.RootObject.RESULT>();
                foreach (var loc in rootObj.RESULTS)
                    if (loc.type.Equals("city"))
                        result.Add(loc);
                return Json(JsonConvert.SerializeObject(result), JsonRequestBehavior.AllowGet);
            }
        }

        [HttpPost]
        public JsonResult ValidateLocation(string city)
        {
            if (WeatherWorker.WeatherParser(city) != null)
                return Json(JsonConvert.SerializeObject(new { isCorrect = true }), JsonRequestBehavior.AllowGet);
            return Json(JsonConvert.SerializeObject(new { isCorrect = false }), JsonRequestBehavior.AllowGet);
        }

        [Authorize]
        [HttpGet]
        public ActionResult SaveLocation(string city)
        {
            string location = WeatherWorker.ConvertFromNameToID(city);

            if (location != null)
                settingService.SetUserLocation(location, User.Identity.Name);


            if (!string.IsNullOrEmpty(Request.QueryString[REDIRECT_URI_PAR]))
                return Redirect(Request.QueryString[REDIRECT_URI_PAR]);
            return RedirectToAction("SelectFile");
        }

        [Authorize]
        public ActionResult SaveFile(string selectedId, string selectedName)
        {
            settingService.SetUserDataFile(selectedName, selectedId, User.Identity.Name);
            if (!string.IsNullOrEmpty(Request.QueryString[REDIRECT_URI_PAR]))
                return Redirect(Request.QueryString[REDIRECT_URI_PAR]);
            return RedirectToAction("CheckApp", new { selectedId, city = Context.City });
        }

        public ActionResult GetIcon(string icon, bool night = false)
        {
            using (var _wb = new WebClient())
            {
                var _url = "http://icons.wxug.com/i/c/k/{0}.gif";
                if (night)
                {
                    icon = "nt_" + icon;
                    _url = "http://icons.wxug.com/i/c/i/{0}.gif";
                }

                var _res = _wb.DownloadData(string.Format(_url, icon));
                return File(_res, "image/gif", icon + ".gif");
            }
        }      
    }
}