using System;
using System.Web;
using System.Web.Mvc;
using System.Web.Routing;
using System.Web.Http;
using log4net;
using log4net.Config;
using Sequencing.WeatherApp.Controllers;

namespace Sequencing.WeatherApp
{
    public class Global : HttpApplication
    {
        void Application_Start(object sender, EventArgs e)
        {
            // Code that runs on application startup
            AreaRegistration.RegisterAllAreas();
            GlobalConfiguration.Configure(WebApiConfig.Register);
            RouteConfig.RegisterRoutes(RouteTable.Routes);
            GlobalFilters.Filters.Add(new CommonDataModelAttribute(), 1);
            XmlConfigurator.Configure();
        }

        protected void Application_Error(object sender, EventArgs e)
        {
            if (Server != null)
            {
                Exception ex = Server.GetLastError();

                if (Response.StatusCode != 404)
                {
                    LogManager.GetLogger(typeof(Global)).Error("Caught in Global.asax", ex);
                }
            }
        }
    }
}