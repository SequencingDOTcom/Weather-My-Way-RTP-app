using System.Net;
using System.ServiceProcess;

namespace Sequencing.WeatherApp.Service
{
    partial class EmailSendService : ServiceBase
    {
        public EmailSendService()
        {
            InitializeComponent();
        }

        private EmailSendProcessor proc;
        private PushNotificationSender pushSender;

        protected override void OnStart(string[] args)
        {
            ServicePointManager.SecurityProtocol = SecurityProtocolType.Tls12;

            pushSender = new PushNotificationSender();
            pushSender.Init();
            proc = new EmailSendProcessor();
            proc.Start();
            
        }

        protected override void OnStop()
        {
            proc.Stop();
            pushSender.Stop();
        }
    }
}
