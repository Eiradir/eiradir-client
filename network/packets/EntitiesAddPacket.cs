using Eiradir.io;
using Godot;

namespace Eiradir.network;

public class EntitiesAddPacket : Packet
{
    public string MapName { get; }
    public Vector3I ChunkPos { get; }
    public NetworkedEntity[] Entities { get; }
    
    private EntitiesAddPacket(string mapName, Vector3I chunkPos, NetworkedEntity[] entities)
    {
        MapName = mapName;
        ChunkPos = chunkPos;
        Entities = entities;
    }
    
    public static EntitiesAddPacket Decode(SupportedInput buf)
    {
        var mapName = buf.ReadString();
        var chunkPos = new Vector3I(buf.ReadByte(), buf.ReadByte(), buf.ReadShort());
        var chunkSize = buf.ReadByte();
        var count = buf.ReadVarInt();
        var entities = new NetworkedEntity[count];
        for (int i = 0; i < count; i++)
        {
            entities[i] = NetworkedEntity.Decode(buf);
        }
        return new EntitiesAddPacket(mapName, chunkPos, entities);
    }
    
    public static void Encode(SupportedOutput buf, EntitiesAddPacket packet)
    {
        buf.WriteString(packet.MapName);
        buf.WriteByte(packet.ChunkPos.X);
        buf.WriteByte(packet.ChunkPos.Y);
        buf.WriteShort(packet.ChunkPos.Z);
        buf.WriteByte(32);
        buf.WriteVarInt(packet.Entities.Length);
        foreach (var entity in packet.Entities)
        {
            entity.Encode(buf);
        }
    }
    
    public override string ToString()
    {
        return $"{nameof(EntitiesAddPacket)}({nameof(MapName)}={MapName}, {nameof(ChunkPos)}={ChunkPos}, {nameof(Entities)}={Entities.Length})";
    }
}