using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using System.ServiceProcess;
using System.Runtime.InteropServices;

using System.Net.Sockets;
using System.Threading;

using System.IO;

namespace UtilLauncherService
{
    public class UtilService : ServiceBase
    {
        private System.Diagnostics.EventLog eventLog;
        public static String service_name = "UtilLauncher";

        Dictionary<string, string> host_info;
        PluginClient.ConfigInfo config_info ;
        //PluginClient.PluginCall caller;
        System.Diagnostics.Process host_proc;

        public UtilService()
        {
            InitializeComponent();
            if(!System.Diagnostics.EventLog.SourceExists("UtilService")){
                System.Diagnostics.EventLog.CreateEventSource("UtilService", "UtilServiceLog");   
            }

            eventLog.Source = "UtilService";
            eventLog.Log = "UtilServiceLog";

            this.ServiceName = service_name;

            this.CanStop = true;
            this.CanPauseAndContinue = false;
            this.AutoLog = true;            
        }

        protected override void OnStart(string[] args)
        {
            // startup stuff
            config_info = new PluginClient.ConfigInfo(PluginClient.SwIntegration.config_path);
            //caller = new PluginClient.PluginCall(config_info);
                        
            host_info = config_info.host_info();

            String logmsg = "";
            logmsg += "Host path: " + host_info["proc_path"] + "\n";
            logmsg += "Host address: " + host_info["host_ip"] + ":" + host_info["host_port"] + "\n";

            eventLog.WriteEntry(logmsg);

            run_host();

        }

        private void run_host()
        {
            ThreadPool.QueueUserWorkItem((x) =>
            {
                // running batch from a service
                //http://social.msdn.microsoft.com/Forums/en-US/8c682320-a60e-48ca-b88c-e51ed3569bda/running-a-batch-file-from-windows-service

                host_proc = PluginClient.PluginCall.start_host_proc(host_info["proc_path"], host_info["proc_name"]);
                
                if (host_proc.Id != 0)
                {
                    eventLog.WriteEntry("Dispatcher host processes successfully started with PID=" + host_proc.Id);
                }
                else
                {
                    if (PluginClient.PluginCall.is_host_proc_running(host_info["proc_name"]))
                    {
                        eventLog.WriteEntry("Dispatcher not started since process is already running");
                    }
                    else
                    {
                        eventLog.WriteEntry("Could not start the dispatcher host processes");
                    }
                }

                host_proc.WaitForExit();
                eventLog.WriteEntry("Dispatcher process exited.");
            });
        }

        protected override void OnStop()
        {
            // TODO: add shutdown stuff
            PluginClient.PluginCall.call_exit("");
            System.Threading.Thread.Sleep(100);
            if (null != host_proc)
            {
                host_proc.Kill();
                eventLog.WriteEntry("host_proc killed");
            }

            eventLog.WriteEntry("In OnStop");
        }

        private void InitializeComponent()
        {
            this.eventLog = new System.Diagnostics.EventLog();
            ((System.ComponentModel.ISupportInitialize)(this.eventLog)).BeginInit();
            ((System.ComponentModel.ISupportInitialize)(this.eventLog)).EndInit();

        }
    }
}
