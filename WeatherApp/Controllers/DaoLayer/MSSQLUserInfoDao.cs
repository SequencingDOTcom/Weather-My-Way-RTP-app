using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Sequencing.WeatherApp.Models;

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

        public UserInfo SaveUser(UserInfo info)
        {
            using (var dbCtx = new WeatherAppDbEntities())
            {
                var firstOrDefault = dbCtx.UserInfoes.FirstOrDefault(user => user.UserName == info.UserName);

                if (firstOrDefault == null)
                {
                    dbCtx.UserInfoes.Add(info);
                    dbCtx.SaveChanges();

                    return info;
                }

                return firstOrDefault;
            }
        }

        public int SelectCount(string userName)
        {
            using (var dbCtx = new WeatherAppDbEntities())
            {
                return dbCtx.UserInfoes.Where(info => info.UserName == userName).Select(info => info).Count();
            }
        }
    }
}