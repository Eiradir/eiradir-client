using Eiradir.io;
using Godot;

namespace Eiradir.network;

public class CameraSetPositionPacket : Packet
{
    public Vector3I Position { get; }
    
    public CameraSetPositionPacket(Vector3I position)
    {
        Position = position;
    }
    
    public static CameraSetPositionPacket Decode(SupportedInput buf)
    {
        var position = buf.ReadVector3Int();
        return new CameraSetPositionPacket(position);
    }
    
    public static void Encode(SupportedOutput buf, CameraSetPositionPacket packet)
    {
        buf.WriteVector3Int(packet.Position);
    }
    
    public override string ToString()
    {
        return $"{nameof(CameraSetPositionPacket)}({nameof(Position)}={Position})";
    }
}