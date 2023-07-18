using System.Net;
using System.Threading.Tasks;
using DotNetty.Transport.Channels;

namespace Eiradir.network;

public interface NetworkContext
{
    IChannel Channel { get; }
    EndPoint Address { get; }
    Task Send(Packet packet);
    Task Respond(Packet packet);
    Task Disconnect();
}