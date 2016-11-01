using Sequencing.WeatherApp.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Sequencing.WeatherApp.Controllers.DaoLayer
{
    public interface IRecommendationsDao
    {
        Recommendation Insert(Recommendation rec);
        List<Recommendation> Find(string weatherCondition, string risk, bool vitD);
        Recommendation Update(Recommendation rec);
    }
}