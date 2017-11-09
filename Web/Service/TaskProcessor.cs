using log4net;
using log4net.Config;
using Sequencing.WeatherApp.Controllers;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

namespace Sequencing.WeatherApp.Service
{
    public abstract class TaskProcessor
    {
        private const int CANCEL_TIMEOUT = 20000;
        private const int ERROR_TIMEOUT = 20000;
        private readonly AutoResetEvent stopProcessing = new AutoResetEvent(false);
        private Thread workerThread;

        protected abstract void ProcessImpl();
        protected abstract void CurrentDomain_OnUnhandledException(object sender, UnhandledExceptionEventArgs e);
        protected abstract void Init();

        private ILog Log
        {
            get { return LogManager.GetLogger(typeof(EmailSendProcessor)); }
        }

        public void Start()
        {
            Init();
            XmlConfigurator.Configure();
            AppDomain.CurrentDomain.UnhandledException += CurrentDomain_OnUnhandledException;
            workerThread = new Thread(Process);
            workerThread.Start(false);
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
                    Log.DebugFormat("Before CheckAllAndSendEmails" + workerThread.ThreadState);
                    ProcessImpl();
                    Log.DebugFormat("After CheckAllAndSendEmails" + workerThread.ThreadState);

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

        public void Stop()
        {
            stopProcessing.Set();
            workerThread.Join(CANCEL_TIMEOUT);
            workerThread.Abort();
        }
    }
}
