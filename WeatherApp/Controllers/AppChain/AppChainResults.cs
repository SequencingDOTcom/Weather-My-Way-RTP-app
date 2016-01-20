using System;

namespace Sequencing.WeatherApp.Controllers.AppChain
{
    /// <summary>
    /// Data holder class for storing executed app-chain results
    /// </summary>
    public class AppChainResults
    {
        /// <summary>
        /// Person susceptibility on melanoma
        /// </summary>
        public RegularQualitativeResultType MelanomaAppChainResult { get; set; }
        /// <summary>
        /// Person vitD dependency
        /// </summary>
        public bool VitDAppChainResult { get; set; }
        /// <summary>
        /// Datetime when app-chains were executed
        /// </summary>
        public DateTime AppChainRunDt { get; set; }
    }
}