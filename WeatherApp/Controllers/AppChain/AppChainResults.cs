using System;

namespace Sequencing.WeatherApp.Controllers.AppChain
{
    /// <summary>
    /// Data holder class for storing executed app-chain results
    /// </summary>
    public class AppChainResults
    {
        public RegularQualitativeResultType MelanomaAppChainResult { get; set; }
        public bool VitDAppChainResult { get; set; }
        public DateTime AppChainRunDt { get; set; }
    }
}