using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Sequencing.WeatherApp.Models;
using log4net;
using System.Data.Entity;

namespace Sequencing.WeatherApp.Controllers.DaoLayer
{
    public class MSSQLSendInfoDao : ISendInfoDao
    {
        public ILog logger = LogManager.GetLogger(typeof(MSSQLSendInfoDao));

        public SendInfo Insert(SendInfo info)
        {
            try
            {
                using (var dbCtx = new WeatherAppDbEntities())
                {
                    dbCtx.SendInfo.Add(info);
                    dbCtx.SaveChanges();
                }
                return info;
            }
            catch (Exception e)
            {
                throw new DaoException("Error inserting user " + info.UserName + " in database", e);
            }
        }

        public SendInfo Find(string userName)
        {
            try
            {
                using (var dbCtx = new WeatherAppDbEntities())
                {                
                    return dbCtx.SendInfo.FirstOrDefault(info => info.UserName == userName);
                }
            }
            catch (Exception e)
            {
                throw new DaoException("Error finding user " + userName + " in database. " + e.Message, e);
            }
        }

        public SendInfo Update(SendInfo sendInfo)
        {
            SendInfo result = null;
            try
            {
                using (var dbCtx = new WeatherAppDbEntities())
                {
                    result = dbCtx.SendInfo.SingleOrDefault(info => info.UserName == sendInfo.UserName);

                    if (result != null)
                    {
                        result.Merge(sendInfo);
                        dbCtx.SaveChanges();

                        return result;
                    }
                    else
                        throw new DaoException("No user " + sendInfo.UserName + " found in database");
                }
            }
            catch (Exception e)
            {
                throw new DaoException("Error updating user " + sendInfo.UserName + " in database. " + e.Message, e);
            }
        }

        public List<long> SelectUsersByName(List<string> info)
        {         
            using (var dbCtx = new WeatherAppDbEntities())
                return dbCtx.SendInfo.Where(x => info.Contains(x.UserName)).Select(x => x.Id).ToList();                         
        }
    }
}