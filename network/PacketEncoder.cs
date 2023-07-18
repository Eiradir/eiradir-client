using DotNetty.Buffers;
using DotNetty.Codecs;
using DotNetty.Transport.Channels;
using Eiradir.io;
using Eiradir.registries;

namespace Eiradir.network;

public class PacketEncoder : MessageToByteEncoder<Packet>
{

    private readonly PacketFactory factory;
    private readonly Registries registries;

    public PacketEncoder(PacketFactory factory, Registries registries)
    {
        this.factory = factory;
        this.registries = registries;
    }

    protected override void Encode(IChannelHandlerContext context, Packet message, IByteBuffer output)
    {
        factory.WritePacket(new SupportedByteBuffer(output, registries), message);
    }
}