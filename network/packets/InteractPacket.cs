using DotNetty.Buffers;
using Eiradir.io;

namespace Eiradir.network;

public class InteractPacket : Packet
{
    public int InteractionId { get; }
    public IByteBuffer Data { get; }

    public InteractPacket(int interactionId, IByteBuffer data)
    {
        InteractionId = interactionId;
        Data = data;
    }

    public static InteractPacket Decode(SupportedInput buf)
    {
        var interactionId = buf.ReadShort();
        var len = buf.ReadShort();
        var data = new byte[len];
        buf.ReadBytes(data);
        return new InteractPacket(interactionId, Unpooled.WrappedBuffer(data));
    }

    public static void Encode(SupportedOutput buf, InteractPacket packet)
    {
        buf.WriteShort(packet.InteractionId);
        buf.WriteShort(packet.Data.ReadableBytes);
        buf.WriteBytes(packet.Data.Array, 0, packet.Data.ReadableBytes);
    }

    public override string ToString()
    {
        return $"{nameof(InteractPacket)}({nameof(InteractionId)}={InteractionId}, {nameof(Data)}={Data})";
    }
}