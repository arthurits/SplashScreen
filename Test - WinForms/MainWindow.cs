using System;
using System.Collections.Generic;
using System.ComponentModel;
using System.Data;
using System.Drawing;
using System.Linq;
using System.Text;
using System.Threading;         // Needed for EventWaitHandle and EventResetMode
using System.Threading.Tasks;
using System.Windows.Forms;

namespace SplashScreenTest
{
    public partial class MainWindow : Form
    {
        public MainWindow()
        {
            InitializeComponent();
        }

        private void MainWindow_Shown(object sender, EventArgs e)
        {
            // Signal the native process (that launched us) to close the splash screen
            using var closeSplashEvent = new EventWaitHandle(false, EventResetMode.ManualReset, "CloseSplashScreenEvent");
            closeSplashEvent.Set();
        }
    }
}
