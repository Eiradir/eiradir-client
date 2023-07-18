using System.Collections.Generic;
using System.IO;
using DotNetty.Buffers;
using DotNetty.Codecs;
using DotNetty.Transport.Channels;
using Eiradir.io;
using Eiradir.registries;

namespace Eiradir.network;

public class PacketDecoder : ByteToMessageDecoder
{

    private readonly PacketFactory factory;
    private readonly Registries registries;

    public PacketDecoder(PacketFactory factory, Registries registries)
    {
        this.factory = factory;
        this.registries = registries;
    }

    protected override void Decode(IChannelHandlerContext context, IByteBuffer input, List<object> output)
    {
        if (input.ReadableBytes != 0)
        {
            var packetId = input.ReadByte();
            var packet = factory.ReadPacket(packetId, new SupportedByteBuffer(input, registries));
            if (packet != null) {
                if (input.ReadableBytes == 0)
                {
                    output.Add(packet);
                } else
                {
                    throw new IOException($"Unexpected packet size, {input.ReadableBytes} extra bytes in packet {packet} (id: {packetId})");
                }
            } else
            {
                throw new IOException($"Received an invalid packet id {packetId}");
            }
        }
    }
}