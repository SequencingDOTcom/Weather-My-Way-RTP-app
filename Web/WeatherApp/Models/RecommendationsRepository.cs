using PagedList;
using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using System.Web;

namespace Sequencing.WeatherApp.Models
{
    public class RecommendationsRepository
    {
        private WeatherAppDbEntities dbCntx;
        private bool disposed = false;


        public RecommendationsRepository()
        {
            this.dbCntx = new WeatherAppDbEntities();
        }

        public void CreateItem(Recommendation item)
        {
            dbCntx.Recommendations.Add(item);
        }

        public void DeleteItem(long? risk, long? vitaminD, long? condId, long? groupId, string lang)
        {
            Recommendation r = dbCntx.Recommendations.Where(rec => (rec.MelanomaRiskId == risk) &&
                                                        (rec.GroupItemId == groupId) &&
                                                        (rec.VitaminDId == vitaminD) &&
                                                        (rec.Language == lang) &&
                                                        (rec.CondId == condId)).FirstOrDefault();
            if (r != null)
                dbCntx.Recommendations.Remove(r);
        }    

        public Recommendation GetItem(long? risk, long? vitaminD, long? condId, long? groupId, string lang)
        {
            return dbCntx.Recommendations.Where(rec =>  (rec.MelanomaRiskId == risk) && 
                                                        (rec.GroupItemId == groupId) && 
                                                        (rec.VitaminDId == vitaminD) && 
                                                        (rec.Language == lang) && 
                                                        (rec.CondId == condId)).FirstOrDefault();
        }

        public IQueryable<Recommendation> GetList()
        {          
            dbCntx.Recommendations.Include(r => r.Condition).Include(r => r.MelanomaRisk).Include(r => r.VitaminD);
            var res = dbCntx.Recommendations.OrderBy(i => i.CondId).Include(r => r.Condition).Include(r => r.MelanomaRisk).Include(r => r.VitaminD);
            

            return res;
        }

        public List<Recommendation> FindItems(int pageIndex, int pageSize)
        {
            return dbCntx.Recommendations.OrderBy(i => i.CondId).Skip((pageIndex - 1) * pageSize).Take(pageSize).ToList();
        }

        public void SaveItem()
        {
            dbCntx.SaveChanges();
        }

        public void UpdateItem(Recommendation item)
        {
            dbCntx.Entry(item).State = EntityState.Modified;
        }

        public void Dispose()
        {
            Dispose(true);
            GC.SuppressFinalize(this);
        }

        public IQueryable<Recommendation> Get()
        {
            return dbCntx.Recommendations;
        }

        public virtual void Dispose(bool disposing)
        {
            if (!this.disposed)
            {
                if (disposing)
                {
                    dbCntx.Dispose();
                }
            }
            this.disposed = true;
        }
    }
}