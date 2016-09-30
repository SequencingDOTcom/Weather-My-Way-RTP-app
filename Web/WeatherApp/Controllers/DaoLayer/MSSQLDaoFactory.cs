using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Sequencing.WeatherApp.Controllers.DaoLayer
{
    public class MSSQLDaoFactory : IDaoFactory
    {
        public IDeviceTokenDao GetDeviceTokenDao()
        {
            return new MSSQLDeviceTokenDao();
        }

        public ISendInfoDao GetSendInfoDao()
        {
            return new MSSQLSendInfoDao();
        }

        public IUserInfoDao GetUserInfoDao()
        {
            return new MSSQLUserInfoDao();
        }
    }
}