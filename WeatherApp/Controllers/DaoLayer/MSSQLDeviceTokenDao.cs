using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Sequencing.WeatherApp.Models;
using log4net;

namespace Sequencing.WeatherApp.Controllers.DaoLayer
{
    public class MSSQLDeviceTokenDao : IDeviceTokenDao
    {
        public ILog logger = LogManager.GetLogger(typeof(MSSQLDeviceTokenDao));

        /// <summary>
        /// Deletes token from database
        /// </summary>
        /// <param name="token"></param>
        public void DeleteToken(string token)
        {
            using (var dbCtx = new WeatherAppDbEntities())
            {
                var singleOrDefault = dbCtx.DeviceTokens.SingleOrDefault(info => info.token == token);

                if (singleOrDefault != null)
                {
                    dbCtx.DeviceTokens.Remove(singleOrDefault);
                    dbCtx.SaveChanges();

                    logger.InfoFormat(string.Format("Token {0} successfully removed from database", token));
                }
                else
                    logger.InfoFormat(string.Format("Token {0} is already removed from database", token));
            }
        }

        /// <summary>
        /// Searches token in database
        /// </summary>
        /// <param name="token"></param>
        /// <returns></returns>
        public DeviceToken FindToken(string token)
        {
            using (var dbCtx = new WeatherAppDbEntities())
            {
                return dbCtx.DeviceTokens.FirstOrDefault(info => info.token == token);
            }
        }


        /// <summary>
        /// Retrieves user tokens
        /// </summary>
        /// <param name="userId"></param>
        /// <param name="deviceType"></param>
        /// <returns></returns>
        public List<string> GetUserTokens(Int64 userId, DeviceType deviceType)
        {
            using (var dbCtx = new WeatherAppDbEntities())
            {
                return dbCtx.DeviceTokens.Where(info => info.userId == userId && info.deviceType == deviceType).Select(info => info.token).ToList();
            }
        }

        /// <summary>
        /// Counts user devices
        /// </summary>
        /// <param name="userId"></param>
        /// <returns></returns>
        public int SelectCount(Int64 userId)
        {
            using (var dbCtx = new WeatherAppDbEntities())
            {
                return dbCtx.DeviceTokens.Where(info => info.userId == userId).Select(info => info).Count();
            }
        }

        public void SaveToken(DeviceToken tokenInfo)
        {
            using (var dbCtx = new WeatherAppDbEntities())
            {
                dbCtx.DeviceTokens.Add(tokenInfo);
                dbCtx.SaveChanges();
            }
        }

        public List<DeviceToken> Select(long userId)
        {
            using (var dbCtx = new WeatherAppDbEntities())
            {
                return dbCtx.DeviceTokens.Where(info => info.userId == userId).Select(info => info).ToList();
            }
        }

        public void UpdateToken(string oldId, string newId)
        {
            using (var dbCtx = new WeatherAppDbEntities())
            {
                var singleOrDefault = dbCtx.DeviceTokens.SingleOrDefault(info => info.token == oldId);

                if (singleOrDefault != null)
                {
                    singleOrDefault.token = newId;
                    dbCtx.SaveChanges();

                    logger.InfoFormat("Old Token {0} successfully updated with new {1} ", oldId, newId);
                }
            }
        }
    }
}