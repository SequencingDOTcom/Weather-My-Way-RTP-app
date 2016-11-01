using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;
using System.Web.Mvc;

namespace Sequencing.WeatherApp.Models
{
    public class RecommendationViewModel
    {
        public PagedList.IPagedList<Recommendation> RecommendationList { get; set; }
        public SelectList MelanomaType { get; set; }
        public SelectList VitD { get; set; }
        public SelectList ConditionList { get; set; }
    }
}