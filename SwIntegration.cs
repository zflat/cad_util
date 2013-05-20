using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO;

using SolidWorks.Interop.sldworks;
using SolidWorks.Interop.swcommands;
using SolidWorks.Interop.swconst;
using SolidWorks.Interop.swpublished;
using SolidWorksTools;

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
    public interface IDispatch3{}

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
        private static String host_proc_path = @"C:\CAD_Setup\Addin\proc.bat"; // @"h:\sandbox\plugin_job\spec\script\plugin_proc.rb";

        public PluginCall(ConfigInfo config_data, SwIntegration caller)
        {
            integration = caller;

            plugins = config_data.list();
            callback_container = build_container();
            config = config_data.host_info();

            host_port = Convert.ToInt32(config["host_port"]);
            host_ip = config["host_ip"];
            host_proc_path = config["proc_path"];
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
                byte[] buffer = encoder.GetBytes(command+"\n");
                int n_sent = s.Send(buffer);
                if (n_sent != buffer.Length)
                {
                    System.Windows.Forms.MessageBox.Show("Command not sent");
                }
                s.Disconnect(true);
            }
            catch (Exception e)
            {
                System.Windows.Forms.MessageBox.Show(e.GetType() + " " + e.Message);
            }
        }

        public static Socket get_connection()
        {
            Socket s = try_connect();
            if (null == s)
            {
                s = run_host();
            }
            return s;
        }
        
        public static Socket run_host()
        {
            Socket s = null;
            using (System.Diagnostics.Process p = new System.Diagnostics.Process())
            {
                System.Diagnostics.ProcessStartInfo info = new System.Diagnostics.ProcessStartInfo(host_proc_path);
                info.Arguments = "";
                info.RedirectStandardInput = true;
                info.RedirectStandardOutput = true;
                info.UseShellExecute = false;
                info.CreateNoWindow = true;
                p.StartInfo = info;
                p.Start();
                while(s == null){
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
            catch(System.Net.Sockets.SocketException)
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
            MethodBuilder mb = tb.DefineMethod( prefixed_callback(command), System.Reflection.MethodAttributes.Public, typeof(void), null);
            System.Reflection.MethodInfo mi = this.GetType().GetMethod(callback_function_name, new Type[] { typeof(string) });
            ILGenerator il = mb.GetILGenerator();
            //il.Emit(OpCodes.Nop);
            il.Emit(OpCodes.Ldstr, command);
            il.EmitCall(OpCodes.Call, mi, null);
            il.Emit(OpCodes.Ret);
        }	
    }

    public class ConfigInfo
    {
        List<Dictionary<String, String>> plugin_list;
        Dictionary<String, String> host_info_dict;

        public ConfigInfo(String str_config_path)
        {
            XDocument config_xml = null;
            plugin_list = new List<Dictionary<string, string>>();
            host_info_dict = new Dictionary<string,string>();

            try
            {
                Stream xml_stream = File.OpenRead(str_config_path);
                config_xml = XDocument.Load(xml_stream);
                xml_stream.Dispose();
            }
            catch (Exception e)
            {
                System.Windows.Forms.MessageBox.Show(e.Message, "Error loading configuration file");
            }

            try
            {
                foreach (XElement plugin_config in config_xml.Descendants())
                {
                    XAttribute command_attrib = plugin_config.Attribute("command");
                    XAttribute host_attrib= plugin_config.Attribute("host_ip");

                    if (command_attrib != null)
                    {
                        Dictionary<String, String> info = new Dictionary<string, string>();
                        info.Add("command", command_attrib.Value);
                        info.Add("name", plugin_config.Attribute("name").Value);
                        info.Add("tooltip", plugin_config.Attribute("tooltip").Value);
                        info.Add("hint", plugin_config.Attribute("hint").Value);
                        plugin_list.Add(info);
                    }

                    
                    if (host_attrib != null)
                    {
                        host_info_dict.Add("host_ip", host_attrib.Value);
                        host_info_dict.Add("host_port", plugin_config.Attribute("host_port").Value);
                        host_info_dict.Add("proc_path", plugin_config.Attribute("proc_path").Value);
                    }
                     
                }
            }
            catch(Exception e)
            {
                System.Windows.Forms.MessageBox.Show(e.Message, "Error parsing the configuration data");
            }
        }

        public List<Dictionary<String, String>> list()
        {
            return plugin_list;
        }

        public Dictionary<String, String> host_info()
        {
            return host_info_dict;
        }
    }
    
    public class SwIntegration : ISwAddin
    {
        public SldWorks mSWApplication;
        private int mSWCookie;

        private CommandManager mCommandManager { get; set; }
        private CommandGroup mCommandGroup;
        private int mCommandGroupId = 15201;
        private string plugin_icon_img_path;
        
        List<Dictionary<String, String>> plugin_info;
        ConfigInfo config_info;

        private bool plugins_populated = false;
        public dynamic callback_handler;
        
        public bool ConnectToSW(object ThisSW, int Cookie)
        {
            mSWApplication = (SldWorks)ThisSW;
            mSWCookie = Cookie;
            mCommandManager = mSWApplication.GetCommandManager(mSWCookie);

            bool result = mSWApplication.SetAddinCallbackInfo(0, this, mSWCookie);
            this.UISetup();
            return result;
        }

        public bool DisconnectFromSW()
        {
            this.UITeardown();
            return true;
        }

        /// <summary>
        /// 
        /// Adding menus and toolbars
        /// http://www.angelsix.com/cms/products/tutorials/64-solidworks/74-solidworks-menus-a-toolbars 
        /// 
        /// Defining dynamic methods
        /// http://msdn.microsoft.com/en-us/library/exczf7b9(v=vs.100).aspx
        /// </summary>
        private void UISetup()
        {
            config_info = new ConfigInfo(@"C:\CAD_Setup\Addin\config.xml");
            plugin_info = config_info.list();

            try
            {
                callback_handler = (new PluginCall(config_info, this)).callback_container;
                mSWApplication.SetAddinCallbackInfo(0, (object)callback_handler, mSWCookie);
            }
            catch (Exception e)
            {
                System.Windows.Forms.MessageBox.Show(e.Message);
            }

            int err = 0;
            mCommandGroup = mCommandManager.CreateCommandGroup2(mCommandGroupId, "Automation Utilities", "Utility scripts for automating tasks.",
                    "Plugins used to automate solidworks tasks", -1, true, ref err);
            
            plugins_populated = !plugins_populated && populate_plugin_commands(mCommandGroup, plugin_info);

            bool commands_added = mCommandGroup.Activate();
        }

        private bool populate_plugin_commands(CommandGroup group, List<Dictionary<String, String>> plugins)
        {
            // if (plugins_populated) { return false; }
            // All command items to be a menu and toolbar item
            int itemType = (int)(swCommandItemType_e.swMenuItem | swCommandItemType_e.swToolbarItem);
            for (int i = 0; i < plugins.Count; i++)
            {
                String cmd = plugins[i]["command"];
                String strCallback = "";

                // Special cases List and Exit
                if (cmd.ToUpper() == "EXIT")
                {
                    strCallback = "call_exit";
                }
                else if (cmd == "")
                {
                    strCallback = "call_list";
                }
                else
                {
                    strCallback = PluginCall.prefixed_callback(plugins[i]["command"]);
                }

                strCallback = PluginCall.prefixed_callback(plugins[i]["command"]);
                group.AddCommandItem2(plugins[i]["name"], (i + 1), plugins[i]["hint"], plugins[i]["tooltip"],
                     0, strCallback, "enable_plugin", 1000 + i, itemType);
            }
            return true;
        }

        public bool reset_plugin_commands()
        {
            remove_commands();
            try
            {
                populate_plugin_commands(mCommandGroup, plugin_info);
            }
            catch (Exception e)
            {
                System.Windows.Forms.MessageBox.Show(e.Message);
            }
            return false;
        }


        public bool enable_plugin()
        {
            return true;
        }

        private void remove_commands()
        {
            int removed = mCommandManager.RemoveCommandGroup2(mCommandGroupId, true);
            if (removed == (int)swRemoveCommandGroupErrors.swRemoveCommandGroup_Failed)
            {
                System.Windows.Forms.MessageBox.Show("Could not remove the command group");
            }
        }

        private void UITeardown()
        {
            remove_commands();
        }

        [ComRegisterFunction()]
        private static void ComRegister(Type t)
        {
            string keyPath = String.Format(@"SOFTWARE\SolidWorks\AddIns\{0:b}", t.GUID);
            using (Microsoft.Win32.RegistryKey rk = Microsoft.Win32.Registry.LocalMachine.CreateSubKey(keyPath))
            {
                rk.SetValue(null, 1); // Load at startup
                rk.SetValue("Title", "Automation Utilities"); // Title
                rk.SetValue("Description", "Utilities to automate actions and processes."); // Description
            }
        }
        [ComUnregisterFunction()]
        private static void ComUnregister(Type t)
        {
            string keyPath = String.Format(@"SOFTWARE\SolidWorks\AddIns\{0:b}", t.GUID);
            Microsoft.Win32.Registry.LocalMachine.DeleteSubKeyTree(keyPath);
        }
    }
}
