using System;
using System.Linq;
using System.Web;
using System.Web.Security;
using Sequencing.WeatherApp.Models;
using Sequencing.WeatherApp.Controllers.DaoLayer;

namespace Sequencing.WeatherApp.Controllers.OAuth
{
    /// <summary>
    /// User authentication worker - stores/retrieves it from data source
    /// </summary>
    public class UserAuthWorker
    {
        private MSSQLDaoFactory factory = new MSSQLDaoFactory();
        private OAuthTokenDaoFactory oauthFactory = new OAuthTokenDaoFactory();

        private readonly string userNameOvr;

        public UserAuthWorker()
        {
        }

        public UserAuthWorker(string userNameOvr)
        {
            this.userNameOvr = userNameOvr;
        }

        /// <summary>
        /// Creates new entry
        /// </summary>
        /// <param name="info"></param>
        /// <returns></returns>
        public UserInfo CreateNewUserToken(TokenInfo info)
        {
            var _userName = oauthFactory.GetOAuthTokenDao().getUser(info.access_token).username;

            var _userInfo = new UserInfo
            {
                AuthToken = info.access_token,
                RefreshToken = info.refresh_token,
                UserName = _userName,
                AuthDt = DateTime.Now
            };

            return factory.GetUserInfoDao().SaveUser(_userInfo);
        }

        /// <summary>
        /// Returns logged in user data
        /// </summary>
        /// <returns></returns>
        public UserInfo GetCurrent()
        {
            if (string.IsNullOrEmpty(userNameOvr))
            {
                var _httpCookie = HttpContext.Current.Request.Cookies[FormsAuthentication.FormsCookieName];
                var _formsAuthenticationTicket = FormsAuthentication.Decrypt(_httpCookie.Value);

                using (var _ctx = new WeatherAppDbEntities())
                {
                    var _id = long.Parse(_formsAuthenticationTicket.UserData);
                    var _userInfo = _ctx.UserInfo.FirstOrDefault(info => info.Id == _id);
                    return _userInfo;
                }
            }
            else
            {
                using (var _ctx = new WeatherAppDbEntities())
                {
                    var _userInfo = _ctx.UserInfo.Where(info => info.UserName == userNameOvr).OrderByDescending(info => info.Id).First();
                    return _userInfo;
                }
            }
        }

        /// <summary>
        /// Updates entry
        /// </summary>
        /// <param name="ui"></param>
        /// <returns></returns>
        public UserInfo UpdateToken(UserInfo ui)
        {
            using (var _ctx = new WeatherAppDbEntities())
            {
                var _userInfo = _ctx.UserInfo.FirstOrDefault(info => info.Id == ui.Id);
                _userInfo.AuthToken = ui.AuthToken;
                _ctx.SaveChanges();
                return _userInfo;
            }
        }
    }
}