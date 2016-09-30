using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Sequencing.WeatherApp.Controllers.DaoLayer
{
    public class GenericResponse
    {
        public int Status { get; set; }
        public int ResponseTime { get; set; }
        public object Data { get; set; }
        public string Message { get; set; }
    }
}