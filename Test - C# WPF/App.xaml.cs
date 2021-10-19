using System;
using System.Collections.Generic;
using System.Configuration;
using System.Data;
using System.Linq;
using System.Threading;         // Needed for CloseSplashScreen function
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Threading; // Needed for Dispatcher method

namespace SplashScreenTester
{
    /// <summary>
    /// Interaction logic for App.xaml
    /// </summary>
    public partial class App : Application
    {
        protected override void OnStartup(StartupEventArgs e)
        {
            Dispatcher.CurrentDispatcher.BeginInvoke(DispatcherPriority.Loaded,
                (DispatcherOperationCallback)delegate { CloseSplashScreen(); return null; },
                this);
            base.OnStartup(e);
        }

        private void CloseSplashScreen()
        {
            // Signal the native process that launched us to close the splash screen
            using var closeSplashEvent = new EventWaitHandle(false,
                EventResetMode.ManualReset,
                "CloseSplashScreenEventSplashScreenStarter")
            closeSplashEvent.Set();
        }
    }
}
