using Sequencing.WeatherApp.Models;
using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using System.Web;

namespace Sequencing.WeatherApp.Models
{
    public class ConditionsRepository 
    {
        private WeatherAppDbEntities dbCntx;
        private bool disposed = false;


        public ConditionsRepository()
        {
            this.dbCntx = new WeatherAppDbEntities();
        }

        public void CreateItem(Condition item)
        {
            dbCntx.Conditions.Add(item);
        }

        public void DeleteItem(long? id)
        {
            Condition con = dbCntx.Conditions.Find(id);
            if (con != null)
                dbCntx.Conditions.Remove(con);
        }

        public Condition GetItem(long? id)
        {
            return dbCntx.Conditions.Find(id);
        }


        public List<Condition> FindItems(int pageIndex, int pageSize)
        {
            return dbCntx.Conditions.OrderBy(i => i.Id).Skip((pageIndex - 1) * pageSize).Take(pageSize).ToList();
        }

        public void SaveItem()
        {
            dbCntx.SaveChanges();
        }

        public void UpdateItem(Condition item)
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

        public List<Condition> GetList()
        {
            return dbCntx.Conditions.ToList();
        }
    }
}