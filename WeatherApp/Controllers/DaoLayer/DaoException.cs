using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Sequencing.WeatherApp.Controllers.DaoLayer
{
    public class DaoException : Exception
    {
        public DaoException(string message, Exception inner) : base(message, inner) { }
        public DaoException(string message) : base(message) { }
    }
}