using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Mandrill.Models;

namespace Sequencing.WeatherApp.Controllers.DaoLayer
{
    public class MSSQLUserInfoDao : IUserInfoDao
    {
        public void DeleteUser(string userName)
        {
            throw new NotImplementedException();
        }

        public UserInfo FindUser(string userName)
        {
            throw new NotImplementedException();
        }

        public void SaveUser(UserInfo info)
        {
            throw new NotImplementedException();
        }
    }
}