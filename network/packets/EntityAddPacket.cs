using Eiradir.io;

namespace Eiradir.network;

public class EntityAddPacket : Packet
{
    public string MapName { get; }
    public NetworkedEntity Entity { get; }
    
    private EntityAddPacket(string mapName, NetworkedEntity entity)
    {
        MapName = mapName;
        Entity = entity;
    }
    
    public static EntityAddPacket Decode(SupportedInput buf)
    {
        var mapName = buf.ReadString();
        var entity = NetworkedEntity.Decode(buf);
        return new EntityAddPacket(mapName, entity);
    }
    
    public static void Encode(SupportedOutput buf, EntityAddPacket packet)
    {
        buf.WriteString(packet.MapName);
        packet.Entity.Encode(buf);
    }
    
    public override string ToString()
    {
        return $"{nameof(EntityAddPacket)}({nameof(MapName)}={MapName}, {nameof(Entity)}={Entity})";
    }
}