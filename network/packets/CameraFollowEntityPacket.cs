using System;
using Eiradir.io;

namespace Eiradir.network;

public class CameraFollowEntityPacket : Packet
{
    public Guid EntityId { get; }
    
    public CameraFollowEntityPacket(Guid entityId)
    {
        EntityId = entityId;
    }
    
    public static CameraFollowEntityPacket Decode(SupportedInput buf)
    {
        var entityId = buf.ReadUniqueId();
        return new CameraFollowEntityPacket(entityId);
    }
    
    public static void Encode(SupportedOutput buf, CameraFollowEntityPacket packet)
    {
        buf.WriteUniqueId(packet.EntityId);
    }
    
    public override string ToString()
    {
        return $"{nameof(CameraFollowEntityPacket)}({nameof(EntityId)}={EntityId})";
    }
}