using Eiradir.io;

namespace Eiradir.network;

public class HudInventorySlotPacket : Packet
{
    public int HudId { get; }
    public int Key { get; }
    public int SlotId { get; }
    public NetworkedItem Item { get; }

    public HudInventorySlotPacket(int hudId, int key, int slotId, NetworkedItem item)
    {
        HudId = hudId;
        Key = key;
        SlotId = slotId;
        Item = item;
    }

    public static HudInventorySlotPacket Decode(SupportedInput buf)
    {
        var hudId = buf.ReadInt();
        var key = buf.ReadByte();
        var slotId = buf.ReadByte();
        var item = NetworkedItem.Decode(buf);
        return new HudInventorySlotPacket(hudId, key, slotId, item);
    }

    public static void Encode(SupportedOutput buf, HudInventorySlotPacket packet)
    {
        buf.WriteInt(packet.HudId);
        buf.WriteByte(packet.Key);
        buf.WriteByte(packet.SlotId);
        packet.Item.Encode(buf);
    }

    public override string ToString()
    {
        return $"{nameof(HudInventorySlotPacket)}({nameof(HudId)}={HudId}, {nameof(Key)}={Key}, {nameof(SlotId)}={SlotId}, {nameof(Item)}={Item})";
    }
}