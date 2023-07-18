using System;
using Eiradir.io;
using Godot;

namespace Eiradir.network;

public class EntityDirectionPacket : Packet
{
    public Guid EntityId { get; }
    public GridDirection Direction { get; }
    
    private EntityDirectionPacket(Guid entityId, GridDirection direction)
    {
        EntityId = entityId;
        Direction = direction;
    }
    
    public static EntityDirectionPacket Decode(SupportedInput buf)
    {
        var entityId = buf.ReadUniqueId();
        var direction = buf.ReadEnum<GridDirection>();
        return new EntityDirectionPacket(entityId, direction);
    }
    
    public static void Encode(SupportedOutput buf, EntityDirectionPacket packet)
    {
        buf.WriteUniqueId(packet.EntityId);
        buf.WriteEnum(packet.Direction);
    }
    
    public override string ToString()
    {            
        return $"{nameof(EntityDirectionPacket)}({nameof(EntityId)}={EntityId}, {nameof(Direction)}={Direction})";
    }
}