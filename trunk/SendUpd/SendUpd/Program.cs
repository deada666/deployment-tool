using System.Text;
using System.Net.Sockets;
using System.IO;

namespace SendUpd
{
    class Program
    {
        static void Main(string[] args)
        {
            try {
                TcpClient tcpclnt = new TcpClient();
                tcpclnt.Connect("127.0.0.1",4857);
                Stream stm = tcpclnt.GetStream();           
                ASCIIEncoding asen= new ASCIIEncoding();
                byte[] ba=asen.GetBytes("/MUPD"); 
                stm.Write(ba,0,ba.Length);
                tcpclnt.Close();
            }
            catch {}
        }
    }
}
