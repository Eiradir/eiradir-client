using Eiradir.io;
using Godot;

namespace Eiradir.network;

public class MoveInputPacket : Packet
{
    public Vector3I Position { get; }
    
    public MoveInputPacket(Vector3I position)
    {
        Position = position;
    }
    
    public static MoveInputPacket Decode(SupportedInput buf)
    {
        var position = buf.ReadVector3Int();
        return new MoveInputPacket(position);
    }
    
    public static void Encode(SupportedOutput buf, MoveInputPacket packet)
    {
        buf.WriteVector3Int(packet.Position);
    }
    
    public override string ToString()
    {            
        return $"{nameof(MoveInputPacket)}({nameof(Position)}={Position})";
    }
}