using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Sequencing.WeatherApp.Controllers.OAuth;

namespace Sequencing.WeatherApp.Controllers.DaoLayer
{
    public interface IFrontendDao
    {
        AuthWorker.DrupalOAuthInfo getUser(string token);
    }
}