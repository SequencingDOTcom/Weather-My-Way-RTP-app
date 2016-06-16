using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using static Sequencing.WeatherApp.Controllers.OAuth.AuthWorker;

namespace Sequencing.WeatherApp.Controllers.DaoLayer
{
    public interface IFrontendDao
    {
        DrupalOAuthInfo getUser(string token);
    }
}