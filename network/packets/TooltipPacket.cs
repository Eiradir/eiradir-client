using Godot;
using Godot.Collections;

namespace Eiradir.network;

using Eiradir.io;

public class TooltipPacket : Packet
{

    enum TooltipItemType
    {
        Title
    }
    
    public int Nonce { get; }
    public Array<Dictionary<string, Variant>> Items { get; }

    public TooltipPacket(int nonce, Array<Dictionary<string, Variant>> items)
    {
        Nonce = nonce;
        Items = items;
    }
    
    public static TooltipPacket Decode(SupportedInput buf)
    {
        var nonce = buf.ReadInt();
        var count = buf.ReadByte();
        var items = new Array<Dictionary<string, Variant>>();
        for (var i = 0; i < count; i++)
        {
            var item = new Dictionary<string, Variant>();
            var type = buf.ReadEnum<TooltipItemType>();
            item["type"] =  (int) type;
            switch (type)
            {
                case TooltipItemType.Title:
                    item["text"] = buf.ReadString();
                    break;
            }
            items.Add(item);
        }
        return new TooltipPacket(nonce, items);
    }
    
    public static void Encode(SupportedOutput buf, TooltipPacket packet)
    {
        throw new System.NotImplementedException();
    }

    public override string ToString()
    {
        return $"{nameof(TooltipPacket)}({nameof(Nonce)}={Nonce}, {nameof(Items)}={Items.Count})";
    }
}