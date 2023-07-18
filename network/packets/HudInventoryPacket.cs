using Eiradir.io;

namespace Eiradir.network;

public class HudInventoryPacket : Packet
{
    public int HudId { get; }
    public int Key { get; }
    
    public NetworkedItem[] Items { get; }
    
    public HudInventoryPacket(int hudId, int key, NetworkedItem[] items)
    {
        HudId = hudId;
        Key = key;
        Items = items;
    }
    
    public static HudInventoryPacket Decode(SupportedInput buf)
    {
        var hudId = buf.ReadInt();
        var key = buf.ReadByte();
        var count = buf.ReadVarInt();
        var items = new NetworkedItem[count];
        for (int i = 0; i < count; i++)
        {
            items[i] = NetworkedItem.Decode(buf);
        }
        return new HudInventoryPacket(hudId, key, items);
    }
    
    public static void Encode(SupportedOutput buf, HudInventoryPacket packet)
    {
        buf.WriteInt(packet.HudId);
        buf.WriteByte(packet.Key);
        buf.WriteVarInt(packet.Items.Length);
        foreach (var item in packet.Items)
        {
            item.Encode(buf);
        }
    }

    public override string ToString()
    {
        return $"{nameof(HudInventoryPacket)}({nameof(HudId)}={HudId}, {nameof(Key)}={Key}, {nameof(Items)}={Items.Length})";
    }
}