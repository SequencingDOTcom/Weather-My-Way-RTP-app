using System.Web.Mvc;
using Sequencing.WeatherApp.Models;

namespace Sequencing.WeatherApp.Controllers
{
    /// <summary>
    /// Error pages controller
    /// </summary>
    public class ErrorController : Controller
    {
        public ViewResult Startup()
        {
            return View("Error", new CommonData());
        }

        public ViewResult NotFound()
        {
            Response.StatusCode = 404;
            return View("NotFound", new CommonData());
        }
    }
}