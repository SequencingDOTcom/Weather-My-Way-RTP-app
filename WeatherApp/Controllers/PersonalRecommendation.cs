namespace Sequencing.WeatherApp.Controllers
{
    /// <summary>
    /// PC data holder
    /// </summary>
    public class PersonalRecommendation
    {
        public string WeatherCondition { get; set; }
        public string Risk { get; set; }
        public string VitD { get; set; }
        public string Recommendation { get; set; }
    }
}