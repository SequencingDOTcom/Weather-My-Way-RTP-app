using Sequencing.WeatherApp.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Sequencing.WeatherApp.Controllers.DaoLayer
{
    public interface ISendInfoDao
    {
        SendInfo Insert(SendInfo info);
        SendInfo Find(string userName);
        SendInfo Update(SendInfo info);

        List<long> SelectUsersByName(List<string> info);

    }
}