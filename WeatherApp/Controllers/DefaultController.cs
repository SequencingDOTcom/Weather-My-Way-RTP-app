using System;
using System.Collections.Generic;
using System.Net;
using System.Web;
using System.Web.Mvc;
using System.Web.Security;
using Sequencing.WeatherApp.Models;

namespace Sequencing.WeatherApp.Controllers
{
    /// <summary>
    /// Main controller for working out the main workflow sequence
    /// </summary>
    public class DefaultController : ControllerBase
    {
        private readonly AuthWorker authWorker = new AuthWorker(Options.OAuthUrl, Options.OAuthRedirectUrl, Options.OAuthSecret, Options.OAuthAppId);

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
                    if (!string.IsNullOrEmpty(Context.DataFileId) && !string.IsNullOrEmpty(Context.City))
                        return RedirectToAction("StartJob", new { selectedId = Context.DataFileId});
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
                //Retrieving token
                var _authInfo = authWorker.GetAuthInfo(code);
                if (_authInfo.Success)
                {
                    var _id = new UserAuthWorker().CreateNewUserToken(_authInfo.Token);
                    var _authTicket = new FormsAuthenticationTicket(1, _id.UserName, DateTime.Now, DateTime.Now.AddDays(15),
                        true, _id.Id.ToString());
                    var encTicket = FormsAuthentication.Encrypt(_authTicket);
                    var faCookie = new HttpCookie(FormsAuthentication.FormsCookieName, encTicket);

                    Response.Cookies.Add(faCookie);

                    return RedirectToAction("Location");
                    
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
                return RedirectToAction("StartJob", new { selectedId = Context.DataFileId, city = Context.City });
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
            return View(new CommonData());
        }

        /// <summary>
        /// Location save
        /// </summary>
        /// <param name="city"></param>
        /// <returns></returns>
        [Authorize]
        public ActionResult SaveLocation(string city)
        {
            new SendInfoWorker(User.Identity.Name).SetLocation(city);
            if (!string.IsNullOrEmpty(Request.QueryString[REDIRECT_URI_PAR]))
                return Redirect(Request.QueryString[REDIRECT_URI_PAR]);
            return RedirectToAction("SelectFile");
        }


        /// <summary>
        /// File save
        /// </summary>
        /// <param name="selectedId"></param>
        /// <param name="selectedName"></param>
        /// <returns></returns>
        [Authorize]
        public ActionResult SaveFile(string selectedId, string selectedName)
        {
            new SendInfoWorker(User.Identity.Name).SetDataFile(selectedName, selectedId);
            if (!string.IsNullOrEmpty(Request.QueryString[REDIRECT_URI_PAR]))
                return Redirect(Request.QueryString[REDIRECT_URI_PAR]);
            return RedirectToAction("StartJob", new { selectedId, city = Context.City });
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
            var _srv = new BackendServiceFacade(Options.ApiUrl);
            var _appStatus = _srv.CheckAppStatus(Convert.ToInt64(jobId));
            var _appStatus2 = _srv.CheckAppStatus(Convert.ToInt64(jobId2));
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
        public ActionResult CheckApp(string jobId, string jobId2)
        {
            return View(new CheckAppData{JobId = jobId, JobId2 = jobId2});
        }

        /// <summary>
        /// Starts app chains
        /// </summary>
        /// <param name="selectedId"></param>
        /// <returns></returns>
        [Authorize]
        public ActionResult StartJob(string selectedId)
        {
            var _srv = new BackendServiceFacade(Options.ApiUrl);
            var _appIdMelanoma = _srv.StartApp(EmailWorker.MELANOMA_APP_CHAIN_ID, new Dictionary<string, string> { { "dataSourceId", selectedId } });
            var _appIdVitD = _srv.StartApp(EmailWorker.VITD_APP_CHAIN_ID, new Dictionary<string, string> { { "dataSourceId", selectedId } });

            return RedirectToAction("CheckApp", new {_appIdMelanoma.jobId, jobId2 = _appIdVitD.jobId });
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
            return RedirectToAction("Results", new {jobId, jobId2, timestamp = DateTime.Now.Ticks});
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
        public ActionResult Results(string jobId, string jobId2, long? timestamp)
        {
            var _ts = new DateTime(timestamp ?? 0);
            if (Math.Abs(DateTime.Now.Subtract(_ts).TotalMinutes) > MINUTES_FOR_RESULTS_USER_REFRESH)
                return RedirectToAction("GoToResults");

            var _isAuthenticated = User.Identity.IsAuthenticated;
            var _userName = User.Identity.Name;
            var _runResult = new RunResultBuilder(_userName, TemperatureMode.F).Build(jobId, jobId2, Context.City);
            ViewBag.ShowEmail = _isAuthenticated;
            ViewBag.EmailSend = new EmailWorker().GetEmailSend(_userName);
            ViewBag.LastJobId = jobId;
            ViewBag.City = Context.City;
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
        public ActionResult VerifyLocation(string city)
        {
            using (var _wb = new WebClient())
            {
                var _res = _wb.DownloadString("http://autocomplete.wunderground.com/aq?query=" + city);
                return Content(_res);
            }
        }
    }
}