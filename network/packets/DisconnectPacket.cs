namespace Eiradir.network;

using Eiradir.io;

public class DisconnectPacket : Packet
{
    public enum DisconnectReason
    {
        UNKNOWN,
        TIMEOUT,
        KICKED,
        BANNED,
        CLIENT_ERROR,
        SERVER_ERROR,
        SERVER_SHUTDOWN,
        FORBIDDEN,
        UNABLE_TO_SPAWN
    }
    
    public DisconnectReason Reason { get; }
    public string Message { get; }
    
    public DisconnectPacket(DisconnectReason reason, string message)
    {
        Reason = reason;
        Message = message;
    }
    
    public static DisconnectPacket Decode(SupportedInput buf)
    {
        var reason = buf.ReadEnum<DisconnectReason>();
        var message = buf.ReadString();
        return new DisconnectPacket(reason, message);
    }
    
    public static void Encode(SupportedOutput buf, DisconnectPacket packet)
    {
        buf.WriteEnum(packet.Reason);
        buf.WriteString(packet.Message);
    }
    
    public override string ToString()
    {
        return $"{nameof(DisconnectPacket)}({nameof(Reason)}={Reason}, {nameof(Message)}={Message})";
    }
}