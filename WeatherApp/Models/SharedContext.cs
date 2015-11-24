using Sequencing.WeatherApp.Controllers.WeatherUnderground;

namespace Sequencing.WeatherApp.Models
{
    /// <summary>
    /// Shared data which is common to each request
    /// </summary>
    public class SharedContext
    {
        public bool IsAuthenticated { get; set; }
        public string UserName { get; set; }
        public string UserEmail { get; set; }
        public string AuthToken { get; set; }
        public string City { get; set; }
        public Forecast10Root Forecast { get; set; }
        public string DataFileId { get; set; }
    }
}