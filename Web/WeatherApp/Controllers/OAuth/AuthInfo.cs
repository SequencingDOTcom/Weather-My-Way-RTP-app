namespace Sequencing.WeatherApp.Controllers.OAuth
{
    /// <summary>
    /// AuthInfo class contains information about OAuth attempt response
    /// </summary>
    public class AuthInfo
    {
        public bool Success { get; set; }
        public string ErrorMessage { get; set; }
        public TokenInfo Token { get; set; }
    }
}