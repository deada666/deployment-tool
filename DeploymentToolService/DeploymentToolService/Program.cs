using System;
using System.Collections.Generic;
using System.ServiceProcess;
using System.Text;

namespace DeploymentToolSvc
{
    static class Program
    {
        /// <summary>
        /// Главная точка входа для приложения.
        /// </summary>
        static void Main()
        {
            ServiceBase[] ServicesToRun;
            ServicesToRun = new ServiceBase[] 
			{ 
				new DeploymentToolSrv() 
			};
            ServiceBase.Run(ServicesToRun);
        }
    }
}
