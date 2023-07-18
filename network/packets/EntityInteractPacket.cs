using System;
using DotNetty.Buffers;
using Eiradir.io;

namespace Eiradir.network;

public class EntityInteractPacket : Packet
{
    public Guid EntityId { get; }
    public int InteractionId { get; }
    public IByteBuffer Data { get; }

    public EntityInteractPacket(Guid entityId, int interactionId, IByteBuffer data)
    {
        EntityId = entityId;
        InteractionId = interactionId;
        Data = data;
    }

    public static EntityInteractPacket Decode(SupportedInput buf)
    {
        var entityId = buf.ReadUniqueId();
        var interactionId = buf.ReadShort();
        var len = buf.ReadShort();
        var data = new byte[len];
        buf.ReadBytes(data);
        return new EntityInteractPacket(entityId, interactionId, Unpooled.WrappedBuffer(data));
    }

    public static void Encode(SupportedOutput buf, EntityInteractPacket packet)
    {
        buf.WriteUniqueId(packet.EntityId);
        buf.WriteShort(packet.InteractionId);
        buf.WriteShort(packet.Data.ReadableBytes);
        buf.WriteBytes(packet.Data.Array, 0, packet.Data.ReadableBytes);
    }

    public override string ToString()
    {
        return $"{nameof(EntityInteractPacket)}({nameof(EntityId)}={EntityId}, {nameof(InteractionId)}={InteractionId}, {nameof(Data)}={Data})";            
    }
}