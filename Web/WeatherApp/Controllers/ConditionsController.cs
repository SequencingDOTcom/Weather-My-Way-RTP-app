using System;
using System.Collections.Generic;
using System.Data;
using System.Data.Entity;
using System.Linq;
using System.Net;
using System.Web;
using System.Web.Mvc;
using Sequencing.WeatherApp.Models;
using PagedList;

namespace Sequencing.WeatherApp.Controllers
{
    public class ConditionsController : Controller
    {
        private ConditionsRepository db = new ConditionsRepository();

        public ActionResult List(int? page)
        {
            var rec = db.GetList();
            int pageSize = 50;
            int pageNumber = (page ?? 1);

            return View(rec.ToPagedList(pageNumber, pageSize));
        }

       
        public ActionResult Create()
        {
            return View();
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Create([Bind(Include = "Id,WeatherCond")] Condition condition)
        {
            if (ModelState.IsValid)
            {
                db.CreateItem(condition);
                db.SaveItem();
                return RedirectToAction("List");
            }

            return View(condition);
        }
        public ActionResult Edit(long? id)
        {
            if (id == null)
            {
                return new HttpStatusCodeResult(HttpStatusCode.BadRequest);
            }
            Condition condition = db.GetItem(id);
            if (condition == null)
            {
                return HttpNotFound();
            }
            return View(condition);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Edit([Bind(Include = "Id,WeatherCond")] Condition condition)
        {
            if (ModelState.IsValid)
            {
                db.UpdateItem(condition);
                db.SaveItem();
                return RedirectToAction("List");
            }
            return View(condition);
        }

        public ActionResult Delete(long? id)
        {
            db.DeleteItem(id);
            db.SaveItem();
            return RedirectToAction("List");
        }
    }
}
