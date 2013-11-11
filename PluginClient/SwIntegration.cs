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
using System.Xml.Linq;
using System.Linq.Expressions;
using System.Threading;

namespace PluginClient
{   
    public class SwIntegration : ISwAddin
    {
        public static String config_path = @"C:\CADetc\Addin\config.xml";


        public SldWorks mSWApplication;
        private int mSWCookie;

        private CommandManager mCommandManager { get; set; }
        private CommandGroup mCommandGroup;
        private int mCommandGroupId_0 = 15201;
        private int mCommandGroupId;
        private int plugin_count_id;
        private string plugin_icon_img_path;
        
        List<Dictionary<String, String>> plugin_info;
        ConfigInfo config_info;

        private bool plugins_populated = false;
        public dynamic callback_handler;
        
        public bool ConnectToSW(object ThisSW, int Cookie)
        {
            mSWApplication = (SldWorks)ThisSW;
            mSWCookie = Cookie;
            mCommandGroupId = mCommandGroupId_0;
            plugin_count_id = mCommandGroupId;

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
        /// Command Manager example
        /// http://help.solidworks.com/2012/English/api/sldworksapi/Create_Flyouts_in_the_CommandManager_Example_CSharp.htm
        /// 
        /// Adding menus and toolbars
        /// http://www.angelsix.com/cms/products/tutorials/64-solidworks/74-solidworks-menus-a-toolbars 
        /// 
        /// Defining dynamic methods
        /// http://msdn.microsoft.com/en-us/library/exczf7b9(v=vs.100).aspx
        /// </summary>
        private void UISetup()
        {
            config_info = new ConfigInfo(config_path);
            plugin_info = config_info.list();

            try
            {
                callback_handler = (new PluginCall(config_info, this)).callback_container;
                mSWApplication.SetAddinCallbackInfo(0, (object)callback_handler, mSWCookie);
            }
            catch (Exception e)
            {
                System.Windows.Forms.MessageBox.Show(e.Message+"\n"+e.StackTrace);
            }

            bool commands_added = add_commands();

            ThreadPool.QueueUserWorkItem((x) =>
            {
                System.Net.Sockets.Socket s = PluginCall.run_host(config_info.host_info()["proc_name"], config_info.host_info()["proc_path"]);
                s.Close();
            });
        }

        private bool add_commands()
        {
            int err = 0;

            String mCommandGroupName = "Utilities";
            int nth_group = mCommandGroupId - mCommandGroupId_0;
            
            if (null != mCommandGroup)
            {
                Marshal.ReleaseComObject(mCommandGroup);
                mCommandGroup = null;
                GC.Collect();
                mCommandGroup = mCommandManager.GetCommandGroup(mCommandGroupId);
            }

            if (null == mCommandGroup)
            {
                mCommandGroup = mCommandManager.CreateCommandGroup2(mCommandGroupId, mCommandGroupName, "Utility scripts for automating tasks.",
                        "Plugins used to automate solidworks tasks", -1, false, ref err);

                if (err != 0 && err != (int)swCreateCommandGroupErrors.swCreateCommandGroup_Success)
                {
                    String str_err_message = "Error creating the command group.\n";
                    if (err == (int)swCreateCommandGroupErrors.swCreateCommandGroup_Failed)
                    {
                        str_err_message += "Failed.\n";
                    }
                    if (err == (int)swCreateCommandGroupErrors.swCreateCommandGroup_Exceeds_ToolBarIDs)
                    {
                        str_err_message += "Exceeds toolbar ids.\n";
                    }
                }
            }

            plugins_populated = !plugins_populated && populate_plugin_commands(mCommandGroup, plugin_info);

            bool activated =  mCommandGroup.Activate();
            //System.Windows.Forms.MessageBox.Show("id:" + mCommandGroupId + "group# " + nth_group + "groups count:" + ((int)mCommandManager.NumberOfGroups));
            return activated;
        }

        private bool remove_commands()
        {
            bool retval = true;
            for (int i = 0; i < 3; i++)
            {
                int removed = mCommandManager.RemoveCommandGroup2(mCommandGroupId, true);
                retval = retval || (removed == (int)swRemoveCommandGroupErrors.swRemoveCommandGroup_Success);
            }
            return retval;
        }

        private bool populate_plugin_commands(CommandGroup group, List<Dictionary<String, String>> plugins)
        {
            // if (plugins_populated) { return false; }
            // All command items to be a menu and toolbar item
            int itemType = (int)(swCommandItemType_e.swMenuItem | swCommandItemType_e.swToolbarItem);
            int n = plugins.Count;
            for (int i = 0; i < n ; i++)
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
                plugin_count_id++;
                strCallback = PluginCall.prefixed_callback(plugins[i]["command"]);
                group.AddCommandItem2(plugins[i]["name"], (i + 1), plugins[i]["hint"], plugins[i]["tooltip"],
                     0, strCallback, "enable_plugin", plugin_count_id, itemType);
            }
            return true;
        }

        public bool reset_plugin_commands()
        {
            return false;

            bool removed = remove_commands();

            if (removed)
            {
                try
                {
                    bool commands_added = add_commands();
                }
                catch (Exception e)
                {
                    System.Windows.Forms.MessageBox.Show(e.Message+"\n"+e.StackTrace);
                }
                return true;
            }
            else
            {
                return false;
            }
        }

        public bool enable_plugin()
        {
            return true;
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
