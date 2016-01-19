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

        protected override void OnStart(string[] args)
        {
            proc = new EmailSendProcessor();
            proc.Start();
        }

        protected override void OnStop()
        {
            proc.Stop();
        }
    }
}
