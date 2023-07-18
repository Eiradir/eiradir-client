using System;
using Eiradir.io;

namespace Eiradir.network;

public class EntityRemovePacket : Packet
{
    public string MapName { get; }
    public Guid EntityId { get; }
    
    public EntityRemovePacket(string mapName, Guid entityId)
    {
        MapName = mapName;
        EntityId = entityId;
    }
    
    public static EntityRemovePacket Decode(SupportedInput buf)
    {
        var name = buf.ReadString();
        var entityId = buf.ReadUniqueId();
        return new EntityRemovePacket(name, entityId);
    }
    
    public static void Encode(SupportedOutput buf, EntityRemovePacket packet)
    {
        buf.WriteString(packet.MapName);
        buf.WriteUniqueId(packet.EntityId);
    }
    
    public override string ToString()
    {
        return $"{nameof(EntityRemovePacket)}({nameof(MapName)}={MapName}, {nameof(EntityId)}={EntityId})";
    }
}