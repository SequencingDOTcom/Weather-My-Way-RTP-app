using Sequencing.WeatherApp.Controllers.OAuth;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Sequencing.WeatherApp.Controllers.DaoLayer
{
    public class OauthTokenDao : IFrontendDao
    {
        public FrontendUser getUser(string token)
        {
            return new FrontendUser
            {
                userName = new AuthWorker(Options.OAuthUrl, Options.OAuthRedirectUrl, Options.OAuthSecret,
                Options.OAuthAppId).GetUserInfo(token).username
            };
        }
    }
}