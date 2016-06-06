using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Sequencing.WeatherApp.Controllers.DaoLayer
{
    public interface IDaoFactory
    {
        IDeviceTokenDao GetDeviceTokenDao();
        ISendInfoDao GetSendInfoDao();
        IUserInfoDao GetUserInfoDao();
    }
}