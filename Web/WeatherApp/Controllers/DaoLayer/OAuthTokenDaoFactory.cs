using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Sequencing.WeatherApp.Controllers.DaoLayer
{
    public class OAuthTokenDaoFactory : IFrontendDaoFactory
    {
        public IFrontendDao GetOAuthTokenDao()
        {
            return new OauthTokenDao();
        }
    }
}