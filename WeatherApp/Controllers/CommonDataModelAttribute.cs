using System.Web.Mvc;
using System.Web.Routing;
using Sequencing.WeatherApp.Controllers.OAuth;
using Sequencing.WeatherApp.Controllers.WeatherUnderground;
using Sequencing.WeatherApp.Models;
using Sequencing.WeatherApp.Controllers.DaoLayer;

namespace Sequencing.WeatherApp.Controllers
{
    /// <summary>
    /// Action filter attribute for filling SharedContext data
    /// </summary>
    public class CommonDataModelAttribute : ActionFilterAttribute
    {
        ISettingService service = new UserSettingService();

        public CommonDataModelAttribute()
        {
        }

        public override void OnActionExecuting(ActionExecutingContext filterContext)
        {
            var controller = filterContext.Controller as ControllerBase;
            if (controller != null)
            {
                (controller).Context = LoadContext(filterContext.RequestContext);
            }
            
            base.OnActionExecuting(filterContext);
        }

        protected SharedContext LoadContext(RequestContext ctx)
        {
            var _sharedContext = new SharedContext();
            var _user = ctx.HttpContext.User;
            if (_user.Identity.IsAuthenticated)
            {
                _sharedContext.IsAuthenticated = true;
                _sharedContext.UserName = _user.Identity.Name;
                var _sendInfo = service.GetInfo(_user.Identity.Name);
                _sharedContext.UserEmail = _sendInfo.UserEmail;
                _sharedContext.City = _sendInfo.City;
                _sharedContext.DataFileId = _sendInfo.DataFileId;
                _sharedContext.AuthToken = new UserAuthWorker().GetCurrent().AuthToken;
                _sharedContext.Forecast = new WeatherWorker(_user.Identity.Name).GetForecast10(_sendInfo.City);
            }
            else
                _sharedContext.IsAuthenticated = false;
            return _sharedContext;
        }

        public override void OnResultExecuting(ResultExecutingContext filterContext)
        {
            var model = filterContext.Controller.ViewData.Model as CommonData;
            var controller = filterContext.Controller as ControllerBase;
            
            if (model != null)
            {
                model.Context = controller != null && controller.Context != null
                    ? controller.Context
                    : LoadContext(filterContext.RequestContext);
                model.Forecast = model.Context.Forecast;
            }

            base.OnResultExecuting(filterContext);
        }
    }
}