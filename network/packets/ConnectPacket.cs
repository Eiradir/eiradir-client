using Eiradir.io;

namespace Eiradir.network;

using System.Collections.Generic;

public class ConnectPacket : Packet
{
    public string Username { get; }
    public string Token { get; }
    public Dictionary<string, string> Properties { get; }

    public ConnectPacket(string username, string token, Dictionary<string, string> properties)
    {
        Username = username;
        Token = token;
        Properties = properties;
    }

    public static ConnectPacket Decode(SupportedInput buf)
    {
        string username = buf.ReadString();
        string loginToken = buf.ReadString();
        Dictionary<string, string> properties = new Dictionary<string, string>();
        int propertyCount = buf.ReadVarInt();
        for (int i = 0; i < propertyCount; i++)
        {
            string key = buf.ReadString();
            string value = buf.ReadString();
            properties.Add(key, value);
        }
        return new ConnectPacket(username, loginToken, properties);
    }

    public static void Encode(SupportedOutput buf, ConnectPacket packet)
    {
        buf.WriteString(packet.Username);
        buf.WriteString(packet.Token);
        buf.WriteVarInt(packet.Properties.Count);
        foreach (KeyValuePair<string, string> entry in packet.Properties)
        {
            buf.WriteString(entry.Key);
            buf.WriteString(entry.Value);
        }
    }
    
    public override string ToString()
    {
        return $"{nameof(ConnectPacket)}({nameof(Username)}={Username}, {nameof(Token)}={Token}, {nameof(Properties)}={Properties})";
    }
}
