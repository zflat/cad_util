using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using System.IO;
using System.Xml.Linq;
using System.Linq.Expressions;

namespace PluginClient
{
    public class ConfigInfo
    {
        List<Dictionary<String, String>> plugin_list;
        Dictionary<String, String> host_info_dict;

        public ConfigInfo(String str_config_path)
        {
            XDocument config_xml = null;
            plugin_list = new List<Dictionary<string, string>>();
            host_info_dict = new Dictionary<string, string>();

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
                    XAttribute host_attrib = plugin_config.Attribute("host_ip");

                    if (command_attrib != null)
                    {
                        Dictionary<String, String> info = new Dictionary<string, string>();
                        info.Add("command", command_attrib.Value);
                        info.Add("id", plugin_config.Attribute("id").Value);
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
                        host_info_dict.Add("proc_name", plugin_config.Attribute("proc_name").Value);
                        host_info_dict.Add("proc_args", plugin_config.Attribute("proc_args").Value);
                    }

                }
            }
            catch (Exception e)
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
}
