using System;
using System.Collections.Generic;
using System.Linq;
using System.Web;

namespace Sequencing.WeatherApp.Controllers.DaoLayer
{
    public class ApplicationException : Exception
    {
        public ApplicationException(string message, Exception inner) : base(message, inner) { }

        public ApplicationException(string message) : base(message) { }
    }
}