using System.Web.Mvc;
using Sequencing.WeatherApp.Models;

namespace Sequencing.WeatherApp.Controllers
{
    /// <summary>
    /// Base controller class for all controllers
    /// </summary>
    public class ControllerBase : Controller
    {
        public SharedContext Context { get; set; }

        public const string REDIRECT_URI_PAR = "r";
    }
}