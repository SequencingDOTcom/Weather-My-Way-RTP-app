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
    public class RecommendationsController : Controller
    {
        private RecommendationsRepository db = new RecommendationsRepository();
        private ConditionsRepository dbCond = new ConditionsRepository();
        private VitaminDRepository dbVit = new VitaminDRepository();
        private MelanomaRiskRepository dbRisk = new MelanomaRiskRepository();

        [HttpGet]
        public ActionResult Index(int? page, long? risk, long? vitD, long? condId)
        {
            IQueryable<Recommendation> rec;

            rec = db.GetList();

            int pageSize = 25;
            int pageNumber = (page ?? 1);

            rec = Filter(rec, risk, vitD, condId);
                
            var condsList = dbCond.GetList();
            condsList.Insert(0, new Condition { WeatherCond = "All", Id = 0 });

            var risksList = dbRisk.GetList();
            risksList.Insert(0, new MelanomaRisk {  Type = "All", Id = 0 });

            var vitDList = dbVit.GetList();          
            vitDList.Insert(0, new VitaminD { Type = null, Id = 0 });

            ViewBag.SearchRisk = risk;
            ViewBag.SearchVitamin = vitD;
            ViewBag.SearchConds = condId;


            RecommendationViewModel model = new RecommendationViewModel
            {
                RecommendationList = rec.ToList().ToPagedList(pageNumber, pageSize),
                ConditionList = new SelectList(condsList, "Id", "WeatherCond"),
                MelanomaType = new SelectList(risksList, "Id", "Type"),
                VitD = new SelectList(vitDList, "Id", "Type")
            };

            return View(model);
        }

        [HttpGet]
        public ActionResult Create()
        {
            ViewBag.CondId = new SelectList(dbCond.GetList(), "Id", "WeatherCond");
            ViewBag.MelanomaRiskId = new SelectList(dbRisk.GetList(), "Id", "Type");
            ViewBag.VitaminDId = new SelectList(dbVit.GetList(), "Id", "Type");
            return View();
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Create([Bind(Include = "Forecast,CondId,VitaminDId,MelanomaRiskId,Language,GroupItemId")] Recommendation recommendation)
        {
            if (ModelState.IsValid)
            {
                db.CreateItem(recommendation);
                db.SaveItem();
                return RedirectToAction("Index");
            }

            ViewBag.CondId = new SelectList(dbCond.GetList(), "Id", "WeatherCond", recommendation.CondId);
            ViewBag.MelanomaRiskId = new SelectList(dbRisk.GetList(), "Id", "Type", recommendation.MelanomaRiskId);
            ViewBag.VitaminDId = new SelectList(dbVit.GetList(), "Id", "Id", recommendation.VitaminDId);
            return View(recommendation);
        }

        [HttpGet]
        public ActionResult Edit(long? risk, long? vitaminD, long? condId, long? groupId, string lang)
        {
            Recommendation recommendation = db.GetItem(risk, vitaminD, condId, groupId, lang);
            if (recommendation == null)
            {
                return HttpNotFound();
            }
            ViewBag.CondId = new SelectList(dbCond.GetList(), "Id", "WeatherCond", recommendation.CondId);
            ViewBag.MelanomaRiskId = new SelectList(dbRisk.GetList(), "Id", "Type", recommendation.MelanomaRiskId);
            ViewBag.VitaminDId = new SelectList(dbVit.GetList(), "Id", "Type", recommendation.VitaminDId);
            return View(recommendation);
        }

        [HttpPost]
        [ValidateAntiForgeryToken]
        public ActionResult Edit([Bind(Include = "Forecast,CondId,VitaminDId,MelanomaRiskId,Language,GroupItemId")] Recommendation recommendation)
        {
            if (ModelState.IsValid)
            {
                db.UpdateItem(recommendation);
                db.SaveItem();
                return RedirectToAction("Index");
            }
            ViewBag.CondId = new SelectList(dbCond.GetList(), "Id", "WeatherCond", recommendation.CondId);
            ViewBag.MelanomaRiskId = new SelectList(dbRisk.GetList(), "Id", "Type", recommendation.MelanomaRiskId);
            ViewBag.VitaminDId = new SelectList(dbVit.GetList(), "Id", "Id", recommendation.VitaminDId);
            return View(recommendation);
        }

        public ActionResult Delete(long? risk, long? vitaminD, long? condId, long? groupId, string lang)
        {
            db.DeleteItem(risk, vitaminD, condId, groupId, lang);
            db.SaveItem();
            return RedirectToAction("Index");
        }


        private IQueryable<Recommendation> Filter(IQueryable<Recommendation> rec, long? risk, long? vitD, long? condId)
        {
            if (condId.HasValue || risk.HasValue || vitD.HasValue)
            {
                if (condId != 0 && risk == 0 && vitD == 0)
                    return rec.Where(p => (p.CondId == condId));

                else if (condId == 0 && risk != 0 && vitD == 0)
                    return rec.Where(p => (p.MelanomaRiskId == risk));

                else if (condId == 0 && risk == 0 && vitD != 0)
                    return rec.Where(p => (p.VitaminDId == vitD));

                else if (condId != 0 && risk != 0 && vitD != 0)
                    return rec.Where(p => (p.VitaminDId == vitD) && (p.MelanomaRiskId == risk) && (p.CondId == condId));

                else if (condId != 0 && risk != 0 && vitD == 0)
                    return rec.Where(p => (p.MelanomaRiskId == risk) && (p.CondId == condId));

                else if (condId != 0 && risk == 0 && vitD != 0)
                    return rec.Where(p => (p.VitaminDId == vitD) && (p.CondId == condId));

                else if (condId == 0 && risk != 0 && vitD != 0)
                    return rec.Where(p => (p.VitaminDId == vitD) && (p.MelanomaRiskId == risk));

                else
                    return db.GetList();
            }
            return rec;
        }
    }
}
