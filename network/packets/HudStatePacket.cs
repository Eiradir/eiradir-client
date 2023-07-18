using System;
using Eiradir.io;

namespace Eiradir.network;

public class HudStatePacket : Packet
{
    public enum HudState
    {
        HIDDEN,
        VISIBLE,
        REMOVED,
    }
    
    public int HudId { get; }
    public int TypeId { get; }
    public HudState State { get; }
    
    public HudStatePacket(int hudId, int typeId, HudState state)
    {
        HudId = hudId;
        TypeId = typeId;
        State = state;
    }
    
    public static HudStatePacket Decode(SupportedInput buf)
    {
        var hudId = buf.ReadInt();
        var typeId = buf.ReadRegistryId("hud_types");
        var state = buf.ReadEnum<HudState>();
        return new HudStatePacket(hudId, typeId, state);
    }
    
    public static void Encode(SupportedOutput buf, HudStatePacket packet)
    {
        buf.WriteInt(packet.HudId);
        buf.WriteRegistryId("hud_types", packet.TypeId);
        buf.WriteEnum(packet.State);
    }
    
    public override string ToString()
    {
        return $"{nameof(HudStatePacket)}({nameof(HudId)}={HudId}, {nameof(TypeId)}={TypeId}, {nameof(State)}={State})";
    }
}