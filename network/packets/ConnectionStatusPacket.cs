namespace Eiradir.network;

using Eiradir.io;

public class ConnectionStatusPacket : Packet
{
    public enum ConnectionStatus
    {
        PRE_AUTH,
        LOADING,
        COMPLETE
    }

    public ConnectionStatus Status { get; }

    public ConnectionStatusPacket(ConnectionStatus status)
    {
        this.Status = status;
    }
    
    public static ConnectionStatusPacket Decode(SupportedInput buf)
    {
        var status = buf.ReadEnum<ConnectionStatus>();
        return new ConnectionStatusPacket(status);
    }
    
    public static void Encode(SupportedOutput buf, ConnectionStatusPacket packet)
    {
        buf.WriteEnum(packet.Status);
    }

    public override string ToString()
    {
        return $"{nameof(ConnectionStatusPacket)}({nameof(Status)}={Status})";
    }
}