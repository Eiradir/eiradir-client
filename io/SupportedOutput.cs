using System;
using Godot;

namespace Eiradir.io;

public interface SupportedOutput
{
    void WriteString(string value);
    void WriteVarInt(int value);
    void WriteUniqueId(Guid id);
    void WriteByte(int value);
    void WriteInt(int value);
    void WriteVector3(Vector3 vector);
    void WriteQuaternion(Quaternion quaternion);
    void WriteVector3Int(Vector3I vector);
    void WriteBytes(byte[] bytes);
    void WriteBytes(byte[] bytes, int offset, int length);
    void WriteLong(long value);
    void WriteShort(int value);
    void WriteFloat(float value);
    void WriteBoolean(bool value);
    void WriteEnum<T>(T value) where T : Enum;
    void WriteRegistryEntry(string registryName, Resource entry);
    void WriteRegistryId(string registryName, int id);
    void WriteColor(Color color);
}