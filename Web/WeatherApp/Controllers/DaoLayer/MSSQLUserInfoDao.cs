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
            try
            {
                using (var dbCtx = new WeatherAppDbEntities())
                {
                    var firstOrDefault = dbCtx.UserInfo.FirstOrDefault(user => user.UserName == info.UserName);

                    if (firstOrDefault == null)
                    {
                        dbCtx.UserInfo.Add(info);
                        dbCtx.SaveChanges();

                        return info;
                    }

                    return firstOrDefault;
                }
            }
            catch (Exception e)
            {
                throw new DaoException("Error inserting  new user token info " + info, e);
            }
        }

        public int SelectCount(string userName)
        {
            try
            {
                using (var dbCtx = new WeatherAppDbEntities())
                {
                    return dbCtx.UserInfo.Where(info => info.UserName == userName).Select(info => info).Count();
                }
            }
            catch (Exception e)
            {
                throw new DaoException("Error counting user access tokens", e);
            }
        }
    }
}