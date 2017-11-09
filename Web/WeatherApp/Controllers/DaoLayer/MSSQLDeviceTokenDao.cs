using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using Sequencing.WeatherApp.Models;
using log4net;
using System.Data.Entity.Core.Objects;

namespace Sequencing.WeatherApp.Controllers.DaoLayer
{
    public class MSSQLDeviceTokenDao : IDeviceTokenDao
    {
        public ILog logger = LogManager.GetLogger(typeof(MSSQLDeviceTokenDao));

        /// <summary>
        /// Deletes token from database
        /// </summary>
        /// <param name="token"></param>
        public void DeleteToken(string token, long userId)
        {
            try
            {
                using (var dbCtx = new WeatherAppDbEntities())
                {
                    var singleOrDefault = dbCtx.DeviceInfo.SingleOrDefault(info => info.userId == userId && info.token == token);
                    if (singleOrDefault != null)
                    {
                        dbCtx.DeviceInfo.Remove(singleOrDefault);
                        dbCtx.SaveChanges();

                        logger.InfoFormat(string.Format("Token {0} successfully removed from database", token));
                    }
                    else
                    {
                        logger.InfoFormat(string.Format("Token {0} is already removed from database", token));
                        throw new DaoException(string.Format("Token {0} is already removed from database", token));
                    }
                }
            }
            catch (Exception e)
            {
                throw new DaoException(string.Format("Error deleting device token {0}. {1}.", token, e.Message), e);
            }
        }

        public long GetUserIdByName(string userName)
        {
            using (var dbCtx = new WeatherAppDbEntities())
            {
                return dbCtx.SendInfo.FirstOrDefault(info => info.UserName == userName).Id;
            }
        }

        /// <summary>
        /// Searches token in database
        /// </summary>
        /// <param name="token"></param>
        /// <returns></returns>
        public DeviceInfo FindToken(string token)
        {
            try
            {
                using (var dbCtx = new WeatherAppDbEntities())
                {
                    return dbCtx.DeviceInfo.FirstOrDefault(info => info.token == token);
                }
            }
            catch (Exception e)
            {
                throw new DaoException(string.Format("Error finding device token {0}. {1}", token, e.Message), e);
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
            try
            {
                using (var dbCtx = new WeatherAppDbEntities())
                {
                    return dbCtx.DeviceInfo.Where(info => info.userId == userId && info.deviceType == deviceType).Select(info => info.token).ToList();
                }
            }
            catch (Exception e)
            {
                throw new DaoException(string.Format("Error getting device token. " + e.Message), e);
            }
        }

        public List<DeviceInfo> SelectTokens(int skip, int take)
        {
            try
            {
                using (var dbCtx = new WeatherAppDbEntities())
                {
                    return dbCtx.DeviceInfo.Where(i => i.appVersion != null).Select(info => info).OrderBy(r => r.id).Skip(skip).Take(take).ToList();
                }
            }
            catch (Exception e)
            {
                throw new DaoException(string.Format("Error getting device token. " + e.Message), e);
            }
        }

        public int CountDeviceInfo()
        {
            try
            {
                using (var dbCtx = new WeatherAppDbEntities())
                {
                    return dbCtx.DeviceInfo.Where(i => i.appVersion!=null).Count();
                }
            }
            catch (Exception e)
            {
                throw new DaoException(string.Format("Error getting device token info. " + e.Message), e);
            }
        }

        /// <summary>
        /// Counts user devices
        /// </summary>
        /// <param name="userId"></param>
        /// <returns></returns>
        public int SelectCount(Int64 userId)
        {
            try
            {
                using (var dbCtx = new WeatherAppDbEntities())
                {
                    return dbCtx.DeviceInfo.Where(info => info.userId == userId).Select(info => info).Count();
                }
            }
            catch (Exception e)
            {
                throw new DaoException(string.Format("Error counting user device tokens. " + e.Message), e);
            }
        }

        public void SaveToken(DeviceInfo tokenInfo)
        {
            try
            {
                using (var dbCtx = new WeatherAppDbEntities())
                {
                    dbCtx.DeviceInfo.Add(tokenInfo);
                    dbCtx.SaveChanges();
                }
            }
            catch (Exception e)
            {
                throw new DaoException(string.Format("Error inserting device token {0}. " + e.Message, tokenInfo.token), e);
            }
        }

        public List<DeviceInfo> Select(long userId)
        {
            try
            {
                using (var dbCtx = new WeatherAppDbEntities())
                {
                    return dbCtx.DeviceInfo.Where(info => info.userId == userId).Select(info => info).ToList();
                }
            }
            catch (Exception e)
            {
                throw new DaoException(string.Format("Error selecting device token. " + e.Message), e);
            }
        }

        public void UpdateToken(string oldId, string newId)
        {
            try
            {
                using (var dbCtx = new WeatherAppDbEntities())
                {
                    var singleOrDefault = dbCtx.DeviceInfo.SingleOrDefault(info => info.token == oldId);

                    if (singleOrDefault != null)
                    {
                        singleOrDefault.token = newId;
                        dbCtx.SaveChanges();

                        logger.ErrorFormat("Old Token {0} successfully updated with new {1} ", oldId, newId);
                    }
                    else
                        throw new DaoException(string.Format("No device token {0} found in database. ", oldId));
                }
            }
            catch (Exception e)
            {
                throw new DaoException(string.Format("Error updating device token {0}. {1}", oldId, e.Message), e);
            }
        }

        public List<DeviceInfo> GetDeviceTokensByUserId(List<long> ids)
        {
            using (var dbCtx = new WeatherAppDbEntities())
            {
                return dbCtx.DeviceInfo.Where(info => ids.Contains(info.userId.Value)).ToList();              
            }
        }
    }
}