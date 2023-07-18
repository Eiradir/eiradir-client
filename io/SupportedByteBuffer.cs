using System;
using System.Text;
using DotNetty.Buffers;
using Eiradir.registries;
using Godot;

namespace Eiradir.io;

public class SupportedByteBuffer : SupportedInput, SupportedOutput
{
    private readonly IByteBuffer buf;
    private readonly Registries registries;

    public SupportedByteBuffer(IByteBuffer buf, Registries registries)
    {
        this.buf = buf;
        this.registries = registries;
    }

    public string ReadString()
    {
        int length = ReadVarInt();
        byte[] buffer = new byte[length];
        buf.ReadBytes(buffer);
        return Encoding.UTF8.GetString(buffer);
    }

    public Guid ReadUniqueId()
    {
        var bytes = new byte[16];
        var mostSignificantBits = buf.ReadLong();
        var mostSignificantBytes = BitConverter.GetBytes(mostSignificantBits);
        var leastSignificantBits = buf.ReadLong();
        var leastSignificantBytes = BitConverter.GetBytes(leastSignificantBits);
        Array.Reverse(mostSignificantBytes);
        Array.Reverse(leastSignificantBytes);
        Array.Copy(mostSignificantBytes, 0, bytes, 0, 8);
        Array.Copy(leastSignificantBytes, 0, bytes, 8, 8);
        Array.Reverse(bytes, 0, 4);
        Array.Reverse(bytes, 4, 2);
        Array.Reverse(bytes, 6, 2);
        return new Guid(bytes);
    }

    public int ReadVarInt()
    {
        int numRead = 0;
        int result = 0;
        byte read;
        do
        {
            read = buf.ReadByte();
            int value = read & 0b01111111;
            result |= value << (7 * numRead);

            numRead++;
            if (numRead > 5)
            {
                throw new InvalidOperationException("VarInt is too big");
            }
        } while ((read & 0b10000000) != 0);

        return result;
    }

    public byte ReadByte()
    {
        return buf.ReadByte();
    }

    public Vector3 ReadVector3()
    {
        float x = buf.ReadFloat();
        float y = buf.ReadFloat();
        float z = buf.ReadFloat();
        return new Vector3(x, y, z);
    }

    public Quaternion ReadQuaternion()
    {
        float x = buf.ReadFloat();
        float y = buf.ReadFloat();
        float z = buf.ReadFloat();
        float w = buf.ReadFloat();
        return new Quaternion(x, y, z, w);
    }

    public Vector3I ReadVector3Int()
    {
        int x = buf.ReadInt();
        int y = buf.ReadInt();
        int z = buf.ReadInt();
        return new Vector3I(x, y, z);
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

    public int ReadInt()
    {
        return buf.ReadInt();
    }

    public void ReadBytes(byte[] bytes)
    {
        buf.ReadBytes(bytes);
    }

    public void WriteString(string value)
    {
        byte[] bytes = Encoding.UTF8.GetBytes(value);
        WriteVarInt(bytes.Length);
        buf.WriteBytes(bytes);
    }

    public void WriteVarInt(int value)
    {
        int rest = value;
        while (true)
        {
            if ((rest & -0x80) == 0)
            {
                buf.WriteByte((byte)rest);
                return;
            }

            buf.WriteByte((byte)(rest & 0x7F | 0x80));
            rest >>= 7;
        }
    }

    public void WriteUniqueId(Guid id)
    {
        var bytes = id.ToByteArray();
        Array.Reverse(bytes, 6, 2);
        Array.Reverse(bytes, 4, 2);
        Array.Reverse(bytes, 0, 4);

        var mostSignificantBytes = new byte[8];
        var leastSignificantBytes = new byte[8];
        Array.Copy(bytes, 0, mostSignificantBytes, 0, 8);
        Array.Copy(bytes, 8, leastSignificantBytes, 0, 8);

        Array.Reverse(mostSignificantBytes);
        Array.Reverse(leastSignificantBytes);

        var mostSignificantBits = BitConverter.ToInt64(mostSignificantBytes, 0);
        var leastSignificantBits = BitConverter.ToInt64(leastSignificantBytes, 0);

        buf.WriteLong(mostSignificantBits);
        buf.WriteLong(leastSignificantBits);
    }

    public void WriteByte(int value)
    {
        buf.WriteByte((byte)value);
    }

    public void WriteInt(int value)
    {
        buf.WriteInt(value);
    }

    public void WriteVector3(Vector3 vector)
    {
        buf.WriteFloat(vector.X);
        buf.WriteFloat(vector.Y);
        buf.WriteFloat(vector.Z);
    }

    public void WriteQuaternion(Quaternion quaternion)
    {
        buf.WriteFloat(quaternion.X);
        buf.WriteFloat(quaternion.Y);
        buf.WriteFloat(quaternion.Z);
        buf.WriteFloat(quaternion.W);
    }
    
    public void WriteVector3Int(Vector3I vector)
    {
        buf.WriteInt(vector.X);
        buf.WriteInt(vector.Y);
        buf.WriteInt(vector.Z);
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
        buf.WriteShort((short)value);
    }

    public void WriteFloat(float value)
    {
        buf.WriteFloat(value);
    }

    public void WriteBoolean(bool value)
    {
        buf.WriteBoolean(value);
    }

    public T ReadEnum<T>() where T : Enum
    {
        var ordinal = buf.ReadByte();
        return (T)Enum.ToObject(typeof(T), ordinal);
    }

    public void WriteEnum<T>(T value) where T : Enum
    {
        buf.WriteByte((byte)Convert.ChangeType(value, typeof(byte)));
    }

    [Obsolete("Use ReadRegistryId instead. Resources should be loaded from a GdScript coroutine.")]
    public Resource ReadRegistryEntry(string registryName)
    {
        var id = buf.ReadShort();
        return id == -1 ? registries.GetRegistry(registryName).LoadEntryByName(ReadString()) : registries.GetRegistry(registryName).LoadEntryById(id);
    }
    
    public int ReadRegistryId(string registryName)
    {
        return buf.ReadShort();
    }

    public void WriteRegistryEntry(string registryName, Resource entry)
    {
        var registry = registries.GetRegistry(registryName);
        var id = registry.GetEntryId(entry);
        buf.WriteShort(id);
        if (id == -1)
        {
            WriteString(registry.GetEntryName(entry));
        }
    }
    
    public void WriteRegistryId(string registryName, int id)
    {
        buf.WriteShort(id);
    }

    public Color ReadColor()
    {
        return new Color((uint)buf.ReadInt());
    }

    public void WriteColor(Color color)
    {
        buf.WriteInt((int)color.ToRgba32());
    }
}