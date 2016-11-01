using log4net;
using Sequencing.WeatherApp.Models;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Sequencing.WeatherApp.Controllers.DaoLayer
{
    public class MSSQLRecommendationsDao : IRecommendationsDao
    {
        public ILog logger = LogManager.GetLogger(typeof(MSSQLSendInfoDao));

        public Recommendation Insert(Recommendation rec)
        {
            try
            {
                using (var dbCtx = new WeatherAppDbEntities())
                {
                    dbCtx.Recommendations.Add(rec);
                    dbCtx.SaveChanges();
                }
                return rec;
            }
            catch (Exception e)
            {
                throw new DaoException("Error inserting recommendation " + rec.Forecast + " in database", e);
            }
        }

       public List<Recommendation> Find(string weatherCondition, string risk, bool vitD)
        {
            try
            {
                using (var dbCtx = new WeatherAppDbEntities())
                {
                    var riskID = dbCtx.MelanomaRisks.Where(r => r.Type == risk).Select(s => s.Id).FirstOrDefault();
                    var vitDID = dbCtx.VitaminDs.Where(v => v.Type == vitD).Select(s => s.Id).FirstOrDefault();
                    var condId = dbCtx.Conditions.Where(v => v.WeatherCond == weatherCondition).Select(s => s.Id).FirstOrDefault();

                    return dbCtx.Recommendations.Where(rec => rec.VitaminDId == vitDID && rec.MelanomaRiskId == riskID && rec.CondId == condId).ToList();
                }
            }
            catch (Exception e)
            {
                throw new DaoException("Error finding recommendations with weather condition" + weatherCondition + " in database. " + e.Message, e);
            }
        }

        public Recommendation Update(Recommendation rec)
        {
            Recommendation result = null;
            try
            {
                using (var dbCtx = new WeatherAppDbEntities())
                {
                    result = dbCtx.Recommendations.SingleOrDefault(info => info.GroupItemId == rec.GroupItemId);

                    if (result != null)
                    {
                        result.Condition = rec.Condition;
                        result.Forecast = rec.Forecast;
                        result.Language = rec.Language;
                        result.MelanomaRiskId = rec.MelanomaRiskId;
                        result.VitaminDId = rec.VitaminDId;
                        dbCtx.SaveChanges();

                        return result;
                    }
                    else
                        throw new DaoException("No recommendation groupId" + rec.GroupItemId + " found in database");
                }
            }
            catch (Exception e)
            {
                throw new DaoException("Error updating recommendation " + rec.GroupItemId + " in database. " + e.Message, e);
            }
        }
    }
}