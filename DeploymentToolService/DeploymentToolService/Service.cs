using System.ServiceProcess;

namespace DeploymentToolSvc
{
    public partial class DeploymentToolSrv : ServiceBase
    {
        private Server srv;

        public DeploymentToolSrv()
        {
            InitializeComponent();
        }

        protected override void OnStart(string[] args)
        {
            srv = new Server();
        }

        protected override void OnStop()
        {
            srv.running = false;
        }
    }
}
