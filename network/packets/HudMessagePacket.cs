﻿using DotNetty.Buffers;
using Eiradir.io;
using Godot;

namespace Eiradir.network;

public class HudMessagePacket : Packet
{
    public int HudId { get; }
    public int Key { get; }
    public IByteBuffer Data { get; }
    
    public HudMessagePacket(int hudId, int key, IByteBuffer data)
    {
        HudId = hudId;
        Key = key;
        Data = data;
    }
    
    public static HudMessagePacket Decode(SupportedInput buf)
    {
        var hudId = buf.ReadInt();
        var key = buf.ReadByte();
        var len = buf.ReadShort();
        var data = new byte[len];
        buf.ReadBytes(data);
        return new HudMessagePacket(hudId, key, Unpooled.WrappedBuffer(data));
    }
    
    public static void Encode(SupportedOutput buf, HudMessagePacket packet)
    {
        buf.WriteInt(packet.HudId);
        buf.WriteByte(packet.Key);
        buf.WriteShort(packet.Data.ReadableBytes);
        buf.WriteBytes(packet.Data.Array, 0, packet.Data.ReadableBytes);
    }

    public override string ToString()
    {
        return $"{nameof(HudMessagePacket)}({nameof(HudId)}={HudId}, {nameof(Key)}={Key}, {nameof(Data)}={Data})";
    }
}