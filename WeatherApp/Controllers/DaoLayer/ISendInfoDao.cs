using Sequencing.WeatherApp.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Sequencing.WeatherApp.Controllers.DaoLayer
{
    public interface ISendInfoDao
    {
        void Insert(SendInfo info);

        SendInfo Find(string userName);

        SendInfo Update(SendInfo info);
   
    }
}