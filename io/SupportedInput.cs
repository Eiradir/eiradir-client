using System;
using Godot;

namespace Eiradir.io;

public interface SupportedInput
{
    string ReadString();
    Guid ReadUniqueId();
    int ReadVarInt();
    byte ReadByte();
    void ReadBytes(byte[] buffer);
    Vector3 ReadVector3();
    Quaternion ReadQuaternion();
    Vector3I ReadVector3Int();
    bool ReadBoolean();
    float ReadFloat();
    long ReadLong();
    double ReadDouble();
    short ReadShort();
    int ReadInt();
    T ReadEnum<T>() where T : Enum;
    [Obsolete("Use ReadRegistryId instead. Resources should be loaded from a GdScript coroutine.")]
    Resource ReadRegistryEntry(string registryName);
    int ReadRegistryId(string registryName);
    Color ReadColor();
}