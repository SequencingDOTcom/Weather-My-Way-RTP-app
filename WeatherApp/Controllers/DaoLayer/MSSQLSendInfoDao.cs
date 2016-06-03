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

        public void Insert(SendInfo info)
        {
            using (var dbCtx = new WeatherAppDbEntities())
            {
                dbCtx.SendInfoes.Add(info);
                dbCtx.SaveChanges();
            }
        }

        public SendInfo Find(string userName)
        {
            using (var dbCtx = new WeatherAppDbEntities())
            {
                return dbCtx.SendInfoes.FirstOrDefault(info => info.UserName == userName);
            }
        }

        public SendInfo Update(SendInfo sendInfo)
        {
            SendInfo result = null;

            using (var dbCtx = new WeatherAppDbEntities())
            {
                result = dbCtx.SendInfoes.SingleOrDefault(info => info.UserName == sendInfo.UserName);

                if (result != null)
                {
                    result.Merge(sendInfo);
                    dbCtx.SaveChanges();
                }
                return result;
            }
        }
    }  
}