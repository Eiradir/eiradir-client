using Eiradir.io;
using Godot;

namespace Eiradir.network;

using System;
using System.Linq;

public class TileMapPacket : Packet, IEquatable<TileMapPacket>
{

    public string Name { get; }
    public Vector3I ChunkPos { get; }
    public int ChunkSize { get; }
    public byte[] Tiles { get; }

    public TileMapPacket(string name, Vector3I chunkPos, int chunkSize, byte[] tiles)
    {
        Name = name;
        ChunkPos = chunkPos;
        ChunkSize = chunkSize;
        Tiles = tiles;
    }

    public static TileMapPacket Decode(SupportedInput buf)
    {
        var name = buf.ReadString();
        var x = buf.ReadByte();
        var y = buf.ReadByte();
        var level = buf.ReadShort();
        var chunkPos = new Vector3I(x, y, level);
        var chunkSize = buf.ReadByte();
        var tiles = new byte[chunkSize * chunkSize];
        buf.ReadBytes(tiles);
        return new TileMapPacket(name, chunkPos, chunkSize, tiles);
    }

    public static void Encode(SupportedOutput buf, TileMapPacket packet)
    {
        buf.WriteString(packet.Name);
        buf.WriteByte(packet.ChunkPos.X);
        buf.WriteByte(packet.ChunkPos.Y);
        buf.WriteShort(packet.ChunkPos.Z);
        buf.WriteByte(packet.ChunkSize);
        buf.WriteBytes(packet.Tiles);
    }

    public bool Equals(TileMapPacket other)
    {
        if (other == null) return false;
        if (ReferenceEquals(this, other)) return true;
        if (GetType() != other.GetType()) return false;
        return ChunkPos.Equals(other.ChunkPos) && Tiles.SequenceEqual(other.Tiles);
    }

    public override bool Equals(object obj)
    {
        return Equals(obj as TileMapPacket);
    }

    public override int GetHashCode()
    {
        var result = ChunkPos.GetHashCode();
        result = 31 * result + Tiles.GetHashCode();
        return result;
    }
    
    public override string ToString()
    {
        return $"{nameof(TileMapPacket)}({nameof(Name)}={Name}, {nameof(ChunkPos)}={ChunkPos}, {nameof(ChunkSize)}={ChunkSize}, {nameof(Tiles)}={Tiles.Length})";
    }
}
