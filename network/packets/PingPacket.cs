using Eiradir.io;

namespace Eiradir.network;

public class PingPacket : Packet
{
    private readonly long challenge;
    public readonly short lastLatency;

    private PingPacket(long challenge, short lastLatency)
    {
        this.challenge = challenge;
        this.lastLatency = lastLatency;
    }

    public static void Encode(SupportedOutput buf, PingPacket packet)
    {
        buf.WriteLong(packet.challenge);
        buf.WriteShort(packet.lastLatency);
    }
    
    public static PingPacket Decode(SupportedInput buf)
    {
        return new PingPacket(buf.ReadLong(), buf.ReadShort());
    }
    
    public override string ToString()
    {
        return $"{nameof(PingPacket)}({nameof(challenge)}={challenge}, {nameof(lastLatency)}={lastLatency})";
    }
}