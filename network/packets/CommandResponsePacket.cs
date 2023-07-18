using Eiradir.io;

namespace Eiradir.network;

public class CommandResponsePacket : Packet
{
    public string Response { get; }

    public CommandResponsePacket(string response)
    {
        this.Response = response;
    }

    public static CommandResponsePacket Decode(SupportedInput buf)
    {
        var response = buf.ReadString();
        return new CommandResponsePacket(response);
    }

    public static void Encode(SupportedOutput buf, CommandResponsePacket packet)
    {
        buf.WriteString(packet.Response);
    }

    public override string ToString()
    {
        return $"{nameof(CommandResponsePacket)}({nameof(Response)}={Response})";
    }
}