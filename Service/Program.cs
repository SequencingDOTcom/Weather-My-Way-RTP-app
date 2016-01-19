using System.ServiceProcess;

namespace Sequencing.WeatherApp.Service
{
    static class Program
    {
        /// <summary>
        /// The main entry point for the application.
        /// </summary>
        static void Main()
        {
            ServiceBase[] ServicesToRun;
            ServicesToRun = new ServiceBase[] 
            { 
                new EmailSendService(),  
            };
            ServiceBase.Run(ServicesToRun);
        }
    }
}
