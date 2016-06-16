using Sequencing.WeatherApp.Controllers.OAuth;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using static Sequencing.WeatherApp.Controllers.OAuth.AuthWorker;

namespace Sequencing.WeatherApp.Controllers.DaoLayer
{
    public class OauthTokenDao : IFrontendDao
    {

        /// <summary>
        /// Gets user info from frontend
        /// </summary>
        /// <param name="token"></param>
        /// <returns></returns>
        public DrupalOAuthInfo getUser(string token)
        {
            return new AuthWorker(Options.OAuthUrl, Options.OAuthRedirectUrl, Options.OAuthSecret,
                Options.OAuthAppId).GetUserInfo(token);
        }
    }
}