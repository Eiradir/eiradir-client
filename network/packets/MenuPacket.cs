using Godot;
using Godot.Collections;

namespace Eiradir.network;

using Eiradir.io;

public class MenuPacket : Packet
{

    enum MenuItemType
    {
        Action
    }
    
    public int Nonce { get; }
    public Array<Dictionary<string, Variant>> Items { get; }

    public MenuPacket(int nonce, Array<Dictionary<string, Variant>> items)
    {
        Nonce = nonce;
        Items = items;
    }
    
    public static MenuPacket Decode(SupportedInput buf)
    {
        var nonce = buf.ReadInt();
        var count = buf.ReadByte();
        var items = new Array<Dictionary<string, Variant>>();
        for (var i = 0; i < count; i++)
        {
            var item = new Dictionary<string, Variant>();
            var type = buf.ReadEnum<MenuItemType>();
            item["type"] = (int) type;
            switch (type)
            {
                case MenuItemType.Action:
                    item["id"] = buf.ReadRegistryId("interactions");
                    item["text"] = buf.ReadString();
                    break;
            }
            items.Add(item);
        }
        return new MenuPacket(nonce, items);
    }
    
    public static void Encode(SupportedOutput buf, MenuPacket packet)
    {
        throw new System.NotImplementedException();
    }

    public override string ToString()
    {
        return $"{nameof(MenuPacket)}({nameof(Nonce)}={Nonce}, {nameof(Items)}={Items.Count})";
    }
}