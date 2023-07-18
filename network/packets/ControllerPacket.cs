using System;
using Eiradir.io;

namespace Eiradir.network;

public class ControllerPacket : Packet
{
    public enum ControllerType
    {
        None,
        Default
    }
    
    public Guid EntityId { get; }
    public ControllerType Type { get; }
    public int Seat { get; }
    
    public ControllerPacket(Guid entityId, ControllerType type, int seat)
    {
        EntityId = entityId;
        Type = type;
        Seat = seat;
    }
    
    public static ControllerPacket Decode(SupportedInput buf)
    {
        var entityId = buf.ReadUniqueId();
        var type = buf.ReadEnum<ControllerType>();
        var seat = buf.ReadByte();
        return new ControllerPacket(entityId, type, seat);
    }
    
    public static void Encode(SupportedOutput buf, ControllerPacket packet)
    {
        buf.WriteUniqueId(packet.EntityId);
        buf.WriteEnum(packet.Type);
        buf.WriteByte((byte) packet.Seat);
    }
    
    public override string ToString()
    {
        return $"{nameof(ControllerPacket)}({nameof(EntityId)}={EntityId}, {nameof(Type)}={Type}, {nameof(Seat)}={Seat})";
    }
}