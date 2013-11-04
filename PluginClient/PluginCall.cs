using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using System.Diagnostics;

using System.Runtime.InteropServices;
using System.Reflection.Emit;
using System.Xml.Linq;
using System.Linq.Expressions;
using System.Dynamic;
using System.Net;
using System.Net.Sockets;

namespace PluginClient
{
    /// <summary>
    /// https://forum.solidworks.com/thread/34702
    /// </summary>
    [ComVisible(true)]
    [Guid("00020400-0000-0000-c000-000000000046"),
    InterfaceType(ComInterfaceType.InterfaceIsIDispatch)]
    public interface IDispatch3 { }

    /// <summary>
    /// 
    /// </summary>
    [ComVisible(true)]
    public class PluginCall
    {
        public static String callback_prefix = "call_plugin";

        private List<Dictionary<String, String>> plugins;
        private Dictionary<String, String> config;
        private static SwIntegration integration = null;

        public object callback_container;

        private static String host_ip = "localhost";
        private static int host_port = 3333;
        private static String host_proc_path = "SPECIFIED IN CONFIG FILE";
        private static String host_proc_name = "SPECIFIED IN CONFIG FILE";

        public PluginCall(ConfigInfo config_data, SwIntegration caller)
        {
            integration = caller;

            plugins = config_data.list();
            callback_container = build_container();
            config = config_data.host_info();

            host_port = Convert.ToInt32(config["host_port"]);
            host_ip = config["host_ip"];
            host_proc_path = config["proc_path"];
            host_proc_name = config["proc_name"];
        }


        public static void call_exit(String arg)
        {
            if (null != integration)
            {
                integration.reset_plugin_commands();
            }
            call_plugin_callback("exit");
        }

        public static void call_list(String arg)
        {
            call_plugin_callback("");
        }

        public static void call_plugin_callback(String command_function)
        {
            String command = command_from_callback_fname(command_function);

            try
            {
                Socket s = get_connection();

                ASCIIEncoding encoder = new ASCIIEncoding();
                byte[] buffer = encoder.GetBytes(command + "\n");
                int n_sent = s.Send(buffer);
                if (n_sent != buffer.Length)
                {
                    System.Windows.Forms.MessageBox.Show("Command not sent");
                }
                s.Disconnect(true);
            }
            catch (Exception e)
            {
                System.Windows.Forms.MessageBox.Show(e.GetType() + " " + e.Message+"\n"+e.StackTrace);
            }
        }

        public static Socket get_connection()
        {
            Socket s = try_connect();
            if (null == s)
            {
                host_win_handle();
                s = run_host();
            }
            return s;
        }

        /**
         * Get the window handle of the running host if
         * it can be found
         */
        public static IntPtr host_win_handle()
        {
            Process[] Processes = Process.GetProcessesByName(host_proc_name);
            IntPtr hWnd = IntPtr.Zero;
            Debug.Write("Processes: " + Processes.Length);
            foreach (Process p in Processes)
            {
                // do something
                System.Windows.Forms.MessageBox.Show(p.ProcessName);
                hWnd = p.Handle;
            }
            return hWnd;
        }

        public static Socket run_host()
        {
            /**
             * Consider sending SW to back of z-index
             * http://stackoverflow.com/questions/9334963/show-a-form-behind-everything-else-and-without-stealing-focus
             * http://msdn.microsoft.com/en-us/library/ms633545(VS.85).aspx
             * http://stackoverflow.com/questions/6724644/process-start-how-to-send-the-launched-executable-to-the-back-c
             */
            Socket s = try_connect();

            if(s != null){
                return s;
            }

            using (System.Diagnostics.Process p = new System.Diagnostics.Process())
            {
                System.Diagnostics.ProcessStartInfo info = new System.Diagnostics.ProcessStartInfo(host_proc_path);
                info.Arguments = "0"; //1 for hidden, 0 for shown
                info.RedirectStandardInput = true;
                info.RedirectStandardOutput = true;
                info.UseShellExecute = false;
                info.CreateNoWindow = true;
                p.StartInfo = info;
                p.Start();
                while (s == null)
                {
                    s = try_connect();
                    System.Threading.Thread.Sleep(10);
                }
            }
            return s;
        }


        public static Socket try_connect()
        {
            // http://tech.pro/tutorial/704/csharp-tutorial-simple-threaded-tcp-server
            IPAddress[] IPs = Dns.GetHostAddresses(host_ip);
            Socket s = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);
            try
            {
                s.Connect(IPs[1], host_port);
            }
            catch (System.Net.Sockets.SocketException)
            {
                s = null;
            }

            return s;
        }

        public static String prefixed_callback(String command)
        {
            return callback_prefix + "_" + command;
        }

        public static String command_from_callback_fname(String callback_function_name)
        {
            return callback_function_name;
        }

        private object build_container()
        {
            Type t_container;
            Guid g = Guid.NewGuid();
            System.Reflection.AssemblyName asmname = new System.Reflection.AssemblyName();
            asmname.Name = "temp" + g;
            AssemblyBuilder asmbuild = System.Threading.Thread.GetDomain().DefineDynamicAssembly(asmname, AssemblyBuilderAccess.Run);
            ModuleBuilder modbuild = asmbuild.DefineDynamicModule("custom_plugin_handler");
            TypeBuilder tb = modbuild.DefineType("callback_handler_type", System.Reflection.TypeAttributes.Public, null, new Type[] { typeof(IDispatch3) });

            populate_callbacks(tb);
            t_container = tb.CreateType();
            return Activator.CreateInstance(t_container);
        }

        private void populate_callbacks(TypeBuilder tb)
        {
            foreach (Dictionary<String, String> p in plugins)
            {
                String cmd = p["command"];
                String callback_name = "call_plugin_callback";

                // special case for exit and list
                if (cmd == "")
                {
                    callback_name = "call_list";
                }
                else if (cmd.ToUpper() == "EXIT")
                {
                    callback_name = "call_exit";
                }

                populate_command_callback(tb, callback_name, cmd);
            }
        }

        private void populate_command_callback(TypeBuilder tb, String callback_function_name, String command)
        {
            MethodBuilder mb = tb.DefineMethod(prefixed_callback(command), System.Reflection.MethodAttributes.Public, typeof(void), null);
            System.Reflection.MethodInfo mi = this.GetType().GetMethod(callback_function_name, new Type[] { typeof(string) });
            ILGenerator il = mb.GetILGenerator();
            //il.Emit(OpCodes.Nop);
            il.Emit(OpCodes.Ldstr, command);
            il.EmitCall(OpCodes.Call, mi, null);
            il.Emit(OpCodes.Ret);
        }
    }

}
