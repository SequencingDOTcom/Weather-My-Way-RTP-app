namespace Sequencing.WeatherApp.Controllers.AppChain
{
    /// <summary>
    /// PR data holder
    /// </summary>
    public class PersonalRecommendation
    {
        /// <summary>
        /// Weather condition from WU (including alerts)
        /// </summary>
        public string WeatherCondition { get; set; }
        /// <summary>
        /// Risk for Melanoma app-chain
        /// </summary>
        public string Risk { get; set; }
        /// <summary>
        /// Detected VitD dependency
        /// </summary>
        public string VitD { get; set; }
        /// <summary>
        /// Final recommendation for Weather/Risk/VitD combo
        /// </summary>
        public string Recommendation { get; set; }
    }
}