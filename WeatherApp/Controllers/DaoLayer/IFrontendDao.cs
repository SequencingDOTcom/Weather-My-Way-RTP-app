using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Sequencing.WeatherApp.Controllers.DaoLayer
{
    public interface IFrontendDao
    {
        FrontendUser getUser(string token);
    }

    public class FrontendUser
    {
        public string userName { get; set; }
    }
}