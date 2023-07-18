using System;
using Eiradir.io;
using Godot;

namespace Eiradir.network;

public class EntityMovePacket : Packet
{
    public Guid EntityId { get; }
    public Vector3I Position { get; }
    
    private EntityMovePacket(Guid entityId, Vector3I position)
    {
        EntityId = entityId;
        Position = position;
    }
    
    public static EntityMovePacket Decode(SupportedInput buf)
    {
        var entityId = buf.ReadUniqueId();
        var position = buf.ReadVector3Int();
        return new EntityMovePacket(entityId, position);
    }
    
    public static void Encode(SupportedOutput buf, EntityMovePacket packet)
    {
        buf.WriteUniqueId(packet.EntityId);
        buf.WriteVector3Int(packet.Position);
    }
    
    public override string ToString()
    {            
        return $"{nameof(EntityMovePacket)}({nameof(EntityId)}={EntityId}, {nameof(Position)}={Position})";
    }
}