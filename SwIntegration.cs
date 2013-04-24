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
        public Type t_container;
        public object callback_container;

        public Socket dispatcher;

        public PluginCall(List<Dictionary<String, String>> plugins_list)
        {
            plugins = plugins_list;
            build_container();
            //connect_dispatcher("localhost", 3333);
        }

        public static void call_plugin_callback(String command_function)
        {
            String command = command_from_callback_fname(command_function);
            
            try
            {
                // http://tech.pro/tutorial/704/csharp-tutorial-simple-threaded-tcp-server
                IPAddress[] IPs = Dns.GetHostAddresses("localhost");
                Socket s = new Socket(AddressFamily.InterNetwork, SocketType.Stream, ProtocolType.Tcp);

                s.Connect(IPs[1], 3333);
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
                System.Windows.Forms.MessageBox.Show(e.Message);
            }
        }

        public static String prefixed_callback(String command)
        {
            return callback_prefix + "_" + command;
        }

        public static String command_from_callback_fname(String callback_function_name)
        {
            return callback_function_name;
        }

        private void build_container()
        {
            Guid g = Guid.NewGuid();
            System.Reflection.AssemblyName asmname = new System.Reflection.AssemblyName();
            asmname.Name = "temp" + g;
            AssemblyBuilder asmbuild = System.Threading.Thread.GetDomain().DefineDynamicAssembly(asmname, AssemblyBuilderAccess.Run);
            ModuleBuilder modbuild = asmbuild.DefineDynamicModule("custom_plugin_handler");
            TypeBuilder tb = modbuild.DefineType("callback_handler_type", System.Reflection.TypeAttributes.Public, null, new Type[] { typeof(IDispatch3) });

            populate_callbacks(tb);
            t_container = tb.CreateType();
            callback_container = Activator.CreateInstance(t_container);
        }
        
        private void populate_callbacks(TypeBuilder tb)
        {
            foreach (Dictionary<String, String> p in plugins)
            {
                populate_command_callback(tb, p["command"]);
            }
        }

        private void populate_command_callback(TypeBuilder tb, String command)
        {
            MethodBuilder mb = tb.DefineMethod("call_plugin_" + command, System.Reflection.MethodAttributes.Public, typeof(void), null);
            System.Reflection.MethodInfo mi = this.GetType().GetMethod("call_plugin_callback", new Type[] { typeof(string) });
            ILGenerator il = mb.GetILGenerator();
            //il.Emit(OpCodes.Nop);
            il.Emit(OpCodes.Ldstr, command);
            il.EmitCall(OpCodes.Call, mi, null);
            il.Emit(OpCodes.Ret);
        }

        private void connect_dispatcher(string host, int port)
        {
            IPAddress[] IPs = Dns.GetHostAddresses(host);

            dispatcher = new Socket(AddressFamily.InterNetwork,
                SocketType.Stream,
                ProtocolType.Tcp);

            dispatcher.Connect(IPs[0], port);
        }		
    }
    
    public class SwIntegration : ISwAddin
    {
        public SldWorks mSWApplication;
        private int mSWCookie;

        private CommandManager mCommandManager { get; set; }
        private int mCommandGroupId = 1;
        private string plugin_icon_img_path;

        private List<DynamicMethod> plugin_callbacks;
        public List<PluginInvoker> plugin_delegates;


        List<Dictionary<String, String>> plugin_info;
        private bool plugins_populated = false;
        public dynamic callback_handler;

        public delegate void PluginInvoker();
        private static Type[] call_plugin_args = { typeof(String) };
        private static System.Reflection.MethodInfo call_plugin_info = typeof(SwIntegration).GetMethod("request_plugin", call_plugin_args);

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
            plugin_callbacks = new List<DynamicMethod>();
            plugin_delegates = new List<PluginInvoker>();

            plugin_info = load_config(@"C:\CAD_Setup\Addin\config.xml");

            try
            {
                callback_handler = (new PluginCall(plugin_info)).callback_container;
                mSWApplication.SetAddinCallbackInfo(0, (object)callback_handler, mSWCookie);
            }
            catch (Exception e)
            {
                System.Windows.Forms.MessageBox.Show(e.Message);
            }

            int err = 0;
            CommandGroup mCommandGroup = mCommandManager.CreateCommandGroup2(mCommandGroupId, "Automation Utilities", "Utility scripts for automating tasks.",
                    "Plugins used to automate solidworks tasks", -1, true, ref err);
            
            plugins_populated = !plugins_populated && populate_plugin_commands(mCommandGroup, plugin_info);

            bool commands_added = mCommandGroup.Activate();
        }

        private bool populate_plugin_commands(CommandGroup group, List<Dictionary<String, String>> plugins)
        {
            if (plugins_populated) { return false; }
            // All command items to be a menu and toolbar item
            int itemType = (int)(swCommandItemType_e.swMenuItem | swCommandItemType_e.swToolbarItem);
            for (int i = 0; i < plugins.Count; i++)
            {
                group.AddCommandItem2(plugins[i]["name"], (i + 1), plugins[i]["hint"], plugins[i]["tooltip"],
                    0, PluginCall.prefixed_callback(plugins[i]["command"]), "enable_plugin", 1000 + i, itemType);  
            }
            return true;
        }

        private List<Dictionary<String, String>> load_config(String str_config_path)
        {
            XDocument config_xml;
            List<Dictionary<String, String>> plugin_list = new List<Dictionary<string, string>>();
            
            try
            {
                Stream xml_stream = File.OpenRead(str_config_path);
                config_xml = XDocument.Load(xml_stream);
                xml_stream.Dispose();
            }
            catch (Exception e)
            {
                System.Windows.Forms.MessageBox.Show(e.Message, "Error loading configuration file");
                return plugin_list;
            }

            try
            {
                foreach (XElement plugin_config in config_xml.Descendants())
                {
                    XAttribute command_attrib = plugin_config.Attribute("command");
                    if (command_attrib != null)
                    {
                        Dictionary<String, String> info = new Dictionary<string, string>();
                        info.Add("command", command_attrib.Value);
                        info.Add("name", plugin_config.Attribute("name").Value);
                        info.Add("tooltip", plugin_config.Attribute("tooltip").Value);
                        info.Add("hint", plugin_config.Attribute("hint").Value);
                        plugin_list.Add(info);
                    }
                }
            }
            catch(Exception e)
            {
                System.Windows.Forms.MessageBox.Show(e.Message, "Error parsing the configuration data");
            }
            return plugin_list;
        }

        public bool enable_plugin()
        {
            return true;
        }

        private void UITeardown()
        {
            throw new NotImplementedException();
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
