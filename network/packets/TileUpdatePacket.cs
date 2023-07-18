using Eiradir.io;
using Eiradir.registries;
using Godot;

namespace Eiradir.network;

public class TileUpdatePacket : Packet
{
    public string MapName { get; }
    public Vector3I Position { get; }
    public int TileId { get; }

    private TileUpdatePacket(string mapName, Vector3I position, int tileId)
    {
        MapName = mapName;
        Position = position;
        TileId = tileId;
    }
    
    public static TileUpdatePacket Decode(SupportedInput buf)
    {
        var mapName = buf.ReadString();
        var position = buf.ReadVector3Int();
        var tileId = buf.ReadRegistryId(Registries.TILES);
        return new TileUpdatePacket(mapName, position, tileId);
    }
    
    public static void Encode(SupportedOutput buf, TileUpdatePacket packet)
    {
        buf.WriteString(packet.MapName);
        buf.WriteVector3Int(packet.Position);
        buf.WriteRegistryId(Registries.TILES, packet.TileId);
    }
    
    public override string ToString()
    {
        return $"{nameof(TileUpdatePacket)}({nameof(MapName)}={MapName}, {nameof(Position)}={Position}, {nameof(TileId)}={TileId})";
    }
}