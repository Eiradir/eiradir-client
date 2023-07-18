using Eiradir.io;
using Godot;

namespace Eiradir.network;

public class TurnInputPacket : Packet
{
    public GridDirection Direction { get; }
    
    public TurnInputPacket(GridDirection direction)
    {
        Direction = direction;
    }
    
    public static TurnInputPacket Decode(SupportedInput buf)
    {
        var direction = buf.ReadEnum<GridDirection>();
        return new TurnInputPacket(direction);
    }
    
    public static void Encode(SupportedOutput buf, TurnInputPacket packet)
    {
        buf.WriteEnum(packet.Direction);
    }
    
    public override string ToString()
    {            
        return $"{nameof(TurnInputPacket)}({nameof(Direction)}={Direction})";
    }
}