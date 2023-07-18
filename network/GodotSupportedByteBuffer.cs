using System;
using DotNetty.Buffers;
using Eiradir.io;
using Eiradir.registries;
using Godot;

namespace Eiradir.network;

public partial class GodotSupportedByteBuffer : GodotObject
{

    private readonly SupportedByteBuffer buf;
    
    public GodotSupportedByteBuffer(SupportedByteBuffer buf)
    {
        this.buf = buf;
    }

    public GodotSupportedByteBuffer(IByteBuffer packetData, RegistriesImpl registries)
    {
        buf = new SupportedByteBuffer(packetData, registries);
    }

    public void WriteString(string value)
    {
        buf.WriteString(value);
    }

    public void WriteVarInt(int value)
    {
        buf.WriteVarInt(value);
    }

    public void WriteUniqueId(string id)
    {
        buf.WriteUniqueId(Guid.Parse(id));
    }

    public void WriteByte(int value)
    {
        buf.WriteByte(value);
    }

    public void WriteInt(int value)
    {
        buf.WriteInt(value);
    }

    public void WriteVector3(Vector3 vector)
    {
        buf.WriteVector3(vector);
    }

    public void WriteQuaternion(Quaternion quaternion)
    {
        buf.WriteQuaternion(quaternion);
    }

    public void WriteVector3Int(Vector3I vector)
    {
        buf.WriteVector3Int(vector);
    }

    public void WriteBytes(byte[] bytes)
    {
        buf.WriteBytes(bytes);
    }

    public void WriteBytes(byte[] bytes, int offset, int length)
    {
        buf.WriteBytes(bytes, offset, length);
    }

    public void WriteLong(long value)
    {
        buf.WriteLong(value);
    }

    public void WriteShort(int value)
    {
        buf.WriteShort(value);
    }

    public void WriteFloat(float value)
    {
        buf.WriteFloat(value);
    }

    public void WriteBoolean(bool value)
    {
        buf.WriteBoolean(value);
    }

    public void WriteEnum<T>(T value) where T : Enum
    {
        buf.WriteEnum(value);
    }

    public void WriteRegistryEntry(string registryName, Resource entry)
    {
        buf.WriteRegistryEntry(registryName, entry);
    }

    public void WriteRegistryId(string registryName, int id)
    {
        buf.WriteRegistryId(registryName, id);
    }

    public void WriteColor(Color color)
    {
        buf.WriteColor(color);
    }

    public string ReadString()
    {
        return buf.ReadString();
    }
    
    public int ReadVarInt()
    {
        return buf.ReadVarInt();
    }
    
    public string ReadUniqueId()
    {
        return buf.ReadUniqueId().ToString();
    }
    
    public byte ReadByte()
    {
        return buf.ReadByte();
    }
    
    public int ReadInt()
    {
        return buf.ReadInt();
    }
    
    public Vector3 ReadVector3()
    {
        return buf.ReadVector3();
    }
    
    public Quaternion ReadQuaternion()
    {
        return buf.ReadQuaternion();
    }
    
    public Vector3I ReadVector3Int()
    {
        return buf.ReadVector3Int();
    }

    public void ReadBytes(byte[] buffer)
    {
        buf.ReadBytes(buffer);
    }

    public bool ReadBoolean()
    {
        return buf.ReadBoolean();
    }
    
    public float ReadFloat()
    {
        return buf.ReadFloat();
    }
    
    public long ReadLong()
    {
        return buf.ReadLong();
    }
    
    public double ReadDouble()
    {
        return buf.ReadDouble();
    }
    
    public short ReadShort()
    {
        return buf.ReadShort();
    }
    
    public T ReadEnum<T>() where T : Enum
    {
        return buf.ReadEnum<T>();
    }
    
    [Obsolete("Use ReadRegistryId instead. Resources should be loaded from a GdScript coroutine.")]
    public Resource ReadRegistryEntry(string registryName)
    {
        return buf.ReadRegistryEntry(registryName);
    }
    
    public int ReadRegistryId(string registryName)
    {
        return buf.ReadRegistryId(registryName);
    }
    
    public Color ReadColor()
    {
        return buf.ReadColor();
    }
}