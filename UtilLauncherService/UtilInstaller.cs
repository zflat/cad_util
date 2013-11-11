using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading.Tasks;

using System.ComponentModel;
using System.Configuration.Install;
using System.ServiceProcess;

namespace UtilLauncherService
{
    [RunInstaller(true)]
    public class UtilInstaller : Installer
    {
        private ServiceProcessInstaller processInstaller;
        private ServiceInstaller serviceInstaller;

        public UtilInstaller()
        {
            processInstaller = new ServiceProcessInstaller();
            serviceInstaller = new ServiceInstaller();

            processInstaller.Account = ServiceAccount.LocalSystem;
            serviceInstaller.StartType = ServiceStartMode.Automatic;
            serviceInstaller.ServiceName = UtilService.service_name;

            Installers.Add(serviceInstaller);
            Installers.Add(processInstaller);
        }
    }
}
