using DotNetty.Buffers;
using Eiradir.io;

namespace Eiradir.network;

public class HudInventorySlotInteractPacket : Packet
{
    public int HudId { get; }
    public int Key { get; }
    public int SlotId { get; }
    public int InteractionId { get; }
    public IByteBuffer Data { get; }

    public HudInventorySlotInteractPacket(int hudId, int key, int slotId, int interactionId, IByteBuffer data)
    {
        HudId = hudId;
        Key = key;
        SlotId = slotId;
        InteractionId = interactionId;
        Data = data;
    }

    public static HudInventorySlotInteractPacket Decode(SupportedInput buf)
    {
        var hudId = buf.ReadInt();
        var key = buf.ReadByte();
        var slotId = buf.ReadByte();
        var interactionId = buf.ReadShort();
        var len = buf.ReadShort();
        var data = new byte[len];
        buf.ReadBytes(data);
        return new HudInventorySlotInteractPacket(hudId, key, slotId, interactionId, Unpooled.WrappedBuffer(data));
    }

    public static void Encode(SupportedOutput buf, HudInventorySlotInteractPacket packet)
    {
        buf.WriteInt(packet.HudId);
        buf.WriteByte(packet.Key);
        buf.WriteByte(packet.SlotId);
        buf.WriteShort(packet.InteractionId);
        buf.WriteShort(packet.Data.ReadableBytes);
        buf.WriteBytes(packet.Data.Array, 0, packet.Data.ReadableBytes);
    }

    public override string ToString()
    {
        return
            $"{nameof(HudInventorySlotPacket)}({nameof(HudId)}={HudId}, {nameof(Key)}={Key}, {nameof(SlotId)}={SlotId}, {nameof(InteractionId)}={InteractionId}, {nameof(Data)}={Data})";
    }
}