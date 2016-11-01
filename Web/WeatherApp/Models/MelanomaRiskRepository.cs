using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using System.Web;

namespace Sequencing.WeatherApp.Models
{
    public class MelanomaRiskRepository
    {
        private WeatherAppDbEntities dbCntx;
        private bool disposed = false;

        public MelanomaRiskRepository()
        {
            this.dbCntx = new WeatherAppDbEntities();
        }

        public void CreateItem(MelanomaRisk item)
        {
            dbCntx.MelanomaRisks.Add(item);
        }

        public void DeleteItem(long? id)
        {
            MelanomaRisk risk = dbCntx.MelanomaRisks.Find(id);
            if (risk != null)
                dbCntx.MelanomaRisks.Remove(risk);
        }

        public MelanomaRisk GetItem(long? id)
        {
            return dbCntx.MelanomaRisks.Find(id);
        }


        public List<MelanomaRisk> FindItems(int pageIndex, int pageSize)
        {
            return dbCntx.MelanomaRisks.OrderBy(i => i.Id).Skip((pageIndex - 1) * pageSize).Take(pageSize).ToList();
        }

        public void SaveItem()
        {
            dbCntx.SaveChanges();
        }

        public void UpdateItem(MelanomaRisk item)
        {
            dbCntx.Entry(item).State = EntityState.Modified;
        }

        public void Dispose()
        {
            Dispose(true);
            GC.SuppressFinalize(this);
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

        public List<MelanomaRisk> GetList()
        {
            return dbCntx.MelanomaRisks.ToList();
        }

    }
}