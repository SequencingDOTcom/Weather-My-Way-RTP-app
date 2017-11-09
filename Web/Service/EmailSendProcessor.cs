using System;
using System.Threading;
using log4net;
using log4net.Config;
using Sequencing.WeatherApp.Controllers;
using Sequencing.WeatherApp.Controllers.UserNotification;

namespace Sequencing.WeatherApp.Service
{
    public class EmailSendProcessor : TaskProcessor
    {

        protected override void CurrentDomain_OnUnhandledException(object sender, UnhandledExceptionEventArgs e)
        {
            LogManager.GetLogger(typeof(EmailSendProcessor)).Fatal(e.ExceptionObject);
        }

        protected override void ProcessImpl()
        {
            new EmailWorker().CheckAllAndSendEmails();
        }
        protected override void Init()
        {

        }
    }
}