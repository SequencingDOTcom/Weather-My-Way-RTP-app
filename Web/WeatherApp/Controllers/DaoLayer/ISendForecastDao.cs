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
        string StorageProcetureCalling(DateTime date, Int64 CondId, Int64 VitaminDId, Int64 MelanomaRiskId, Int64 UserId);
    }
}