using System.Text;
using System.Net.Sockets;
using System.Threading;
using System.Net;
using System.Windows.Forms;
using System;

namespace DeploymentToolSvc
{
    class Server
    {
        private TcpListener tcpListener;
        private Thread listenThread;
        public bool running;

        public Server(bool run = true)
        {
            this.running = run;
            this.tcpListener = new TcpListener(IPAddress.Any, 4857);
            this.listenThread = new Thread(new ThreadStart(ListenForClients));
            this.listenThread.Start();
        }

        private string exepath()
        {
            string path = Application.ExecutablePath;
            int pos = path.LastIndexOf('\\');
            return path.Substring(0, pos + 1);
        }

        private void ListenForClients()
        {
            this.tcpListener.Start();

            while (running)
            {
                Socket s = tcpListener.AcceptSocket();
                HandleClientComm(s);
                Thread.Sleep(25);
            }

            this.tcpListener.Stop();
        }

        private void HandleClientComm(Socket socket)
        {
            byte[] message = new byte[100];
            Socket sock = socket;

            int bytesRead = sock.Receive(message);
            string receiveddata = "";
            for (int i = 0; i < bytesRead; i++)
                receiveddata += Convert.ToChar(message[i]);

            sock.Close();

            String pspath = System.Environment.GetEnvironmentVariable("windir") + "\\System32\\WindowsPowershell\\v1.0\\powershell.exe";
            if (receiveddata.Equals("/FUPD"))
            {
                try
                {
                    System.Diagnostics.Process.Start(pspath, "-ExecutionPolicy Unrestricted -WindowStyle Hidden -file \"" + exepath() + "sysupd.ps1\" /FORCE");
                }
                catch { }
            }
            else if (receiveddata.Equals("/MUPD"))
            {
                try
                {
                    System.Diagnostics.Process.Start(pspath, "-ExecutionPolicy Unrestricted -WindowStyle Hidden -file \"" + exepath() + "sysupd.ps1\"");
                }
                catch { }
            }
        }
    }
}
