using System;
using System.Collections.Generic;
using System.Data.Entity;
using System.Linq;
using System.Web;

namespace Sequencing.WeatherApp.Models
{
    public class VitaminDRepository
    {
        private WeatherAppDbEntities dbCntx;
        private bool disposed = false;


        public VitaminDRepository()
        {
            this.dbCntx = new WeatherAppDbEntities();
        }

        public void CreateItem(VitaminD item)
        {
            dbCntx.VitaminDs.Add(item);
        }

        public void DeleteItem(long?[] par)
        {
            VitaminD vit = dbCntx.VitaminDs.Find(par);
            if (vit != null)
                dbCntx.VitaminDs.Remove(vit);
        }

        public VitaminD GetItem(long?[] par)
        {
            return dbCntx.VitaminDs.Find(par);
        }


        public List<VitaminD> FindItems(int pageIndex, int pageSize)
        {
            return dbCntx.VitaminDs.OrderBy(i => i.Id).Skip((pageIndex - 1) * pageSize).Take(pageSize).ToList();
        }

        public void SaveItem()
        {
            dbCntx.SaveChanges();
        }

        public void UpdateItem(VitaminD item)
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

        public List<VitaminD> GetList()
        {
            return dbCntx.VitaminDs.ToList();
        }

    }
}