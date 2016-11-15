using Sequencing.WeatherApp.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Sequencing.WeatherApp.Controllers.DaoLayer
{
    public interface ISendForecastDao
    {
        SendForecast Insert(SendForecast send);
        SendForecast Find(string userName);
        string StorageProcetureCalling(DateTime date, Int64 condId, Int64 vitaminDId, Int64 melanomaRiskId, Int64 userId, Int64 appType);
    }
}