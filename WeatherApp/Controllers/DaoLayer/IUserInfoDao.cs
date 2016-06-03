using Mandrill.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Sequencing.WeatherApp.Controllers.DaoLayer
{
    public interface IUserInfoDao
    {
        void SaveUser(UserInfo info);

        void DeleteUser(string userName);

        UserInfo FindUser(string userName);
    }
}