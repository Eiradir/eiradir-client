using DotNetty.Buffers;
using Eiradir.io;
using Godot;

namespace Eiradir.network;

public class TileInteractPacket : Packet
{
    public Vector3I Position { get; }
    public int InteractionId { get; }
    public IByteBuffer Data { get; }

    public TileInteractPacket(Vector3I position, int interactionId, IByteBuffer data)
    {
        Position = position;
        InteractionId = interactionId;
        Data = data;
    }

    public static TileInteractPacket Decode(SupportedInput buf)
    {
        var position = buf.ReadVector3Int();
        var interactionId = buf.ReadShort();
        var len = buf.ReadShort();
        var data = new byte[len];
        buf.ReadBytes(data);
        return new TileInteractPacket(position, interactionId, Unpooled.WrappedBuffer(data));
    }

    public static void Encode(SupportedOutput buf, TileInteractPacket packet)
    {
        buf.WriteVector3Int(packet.Position);
        buf.WriteShort(packet.InteractionId);
        buf.WriteShort(packet.Data.ReadableBytes);
        buf.WriteBytes(packet.Data.Array, 0, packet.Data.ReadableBytes);
    }

    public override string ToString()
    {
        return $"{nameof(TileInteractPacket)}({nameof(Position)}={Position}, {nameof(InteractionId)}={InteractionId}, {nameof(Data)}={Data})";            
    }
}