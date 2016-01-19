using System;
using System.Threading;
using log4net;
using log4net.Config;
using Sequencing.WeatherApp.Controllers;
using Sequencing.WeatherApp.Controllers.UserNotification;

namespace Sequencing.WeatherApp.Service
{
    public class EmailSendProcessor
    {
        private const int CANCEL_TIMEOUT = 20000;
        private const int ERROR_TIMEOUT = 20000;
        private readonly AutoResetEvent stopProcessing = new AutoResetEvent(false);
        private Thread workerThread;

        private ILog Log
        {
            get { return LogManager.GetLogger(typeof(EmailSendProcessor)); }
        }

        public void Start()
        {
            XmlConfigurator.Configure();
            AppDomain.CurrentDomain.UnhandledException += CurrentDomain_OnUnhandledException;
            workerThread = new Thread(Process);
            workerThread.Start(false);
        }

        private void CurrentDomain_OnUnhandledException(object sender, UnhandledExceptionEventArgs e)
        {
            LogManager.GetLogger(typeof(EmailSendProcessor)).Fatal(e.ExceptionObject);
        }


        public void Process(object stopRun)
        {
            bool _stop = false;
            while (!_stop)
            {
                if (stopProcessing.WaitOne(0, false))
                    break;
                double _secondsToWait;
                try
                {
                    ProcessImpl();
                    _secondsToWait = Options.EmailCheckDelay;
                }
                catch (Exception ex)
                {
                    Log.Fatal(ex);
                    _secondsToWait = ERROR_TIMEOUT / 1000;
                }
                if ((bool)stopRun)
                {
                    break;
                }
                int _millisecondsTimeout = Convert.ToInt32(_secondsToWait * 1000);
                Log.DebugFormat("Waiting for {0} ms", _millisecondsTimeout);
                int _idx = WaitHandle.WaitAny(new WaitHandle[] { stopProcessing }, _millisecondsTimeout, false);
                _stop = _idx == 0;
            }
        }

        private void ProcessImpl()
        {
            new EmailWorker().CheckAllAndSendEmails();
        }

        public void Stop()
        {
            stopProcessing.Set();
            workerThread.Join(CANCEL_TIMEOUT);
            workerThread.Abort();
        }
    }
}