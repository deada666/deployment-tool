using System.Text;
using System.Net.Sockets;
using System.IO;

namespace SendUpdateRemote
{
    class Program
    {
        static void Main(string[] args)
        {
            try
            {
                TcpClient tcpclnt = new TcpClient();
                tcpclnt.Connect(args[0], 4857);
                Stream stm = tcpclnt.GetStream();
                ASCIIEncoding asen = new ASCIIEncoding();
                byte[] ba = asen.GetBytes("/FUPD");
                stm.Write(ba, 0, ba.Length);
                tcpclnt.Close();
            }
            catch { }
        }
    }
}