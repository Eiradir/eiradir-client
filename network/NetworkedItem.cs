using Eiradir.io;
using Godot;
using Godot.Collections;

namespace Eiradir.network;

public partial class NetworkedItem : RefCounted
{
    public int IsoId;
    public int Count;
    public Dictionary<NetworkedDataKey, Variant> Properties;

    public static NetworkedItem Decode(SupportedInput buf)
    {
        var count = buf.ReadShort();
        var isoId = count > 0 ? buf.ReadShort() : 0;
        var dataCount = count > 0 ? buf.ReadByte() : 0;
        var properties = new Dictionary<NetworkedDataKey, Variant>();
        for (var i = 0; i < dataCount; i++)
        {
            var key = buf.ReadEnum<NetworkedDataKey>();
            switch (key)
            {
                case NetworkedDataKey.Color:
                    properties[key] = buf.ReadColor();
                    break;
                default:
                    throw new System.Exception("Invalid network item data key " + key);
            }
        }

        return new NetworkedItem
        {
            IsoId = isoId,
            Count = count,
            Properties = properties
        };
    }
    
    public void Encode(SupportedOutput buf)
    {
        buf.WriteShort(Count);
        if (Count > 0)
        {
            buf.WriteShort(IsoId);
        }
    }
    
    public override string ToString()
    {
        return $"{nameof(NetworkedItem)}({nameof(IsoId)}={IsoId}, {nameof(Count)}={Count}, {nameof(Properties)}={Properties})";
    }
}