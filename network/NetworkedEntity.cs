using Eiradir.io;
using Godot;
using Godot.Collections;

namespace Eiradir.network;

public partial class NetworkedEntity : RefCounted
{
    public string Id;
    public Vector3I Position;
    public GridDirection Direction;
    public int IsoId;
    public Dictionary<NetworkedDataKey, Variant> Properties;

    public static NetworkedEntity Decode(SupportedInput buf)
    {
        var id = buf.ReadUniqueId().ToString();
        var position = buf.ReadVector3Int();
        var direction = buf.ReadEnum<GridDirection>();
        var isoId = buf.ReadShort();
        var dataCount = buf.ReadByte();
        var properties = new Dictionary<NetworkedDataKey, Variant>();
        for (var i = 0; i < dataCount; i++)
        {
            var key = buf.ReadEnum<NetworkedDataKey>();
            switch (key)
            {
                case NetworkedDataKey.Name:
                    properties[key] = buf.ReadString();
                    break;
                case NetworkedDataKey.Color:
                    properties[key] = buf.ReadColor();
                    break;
                case NetworkedDataKey.Paperdolls:
                    var paperdollCount = buf.ReadByte();
                    var paperdolls = new Array<int>();
                    for (var j = 0; j < paperdollCount; j++)
                    {
                        paperdolls.Add(buf.ReadShort());
                    }
                    properties[key] = paperdolls;
                    break;
                case NetworkedDataKey.PaperdollColors:
                    var paperdollColorCount = buf.ReadByte();
                    var paperdollColors = new Array<Color>();
                    for (var j = 0; j < paperdollColorCount; j++)
                    {
                        paperdollColors.Add(buf.ReadColor());
                    }
                    properties[key] = paperdollColors;
                    break;
                case NetworkedDataKey.VisualTraits:
                    var visualTraitCount = buf.ReadByte();
                    var visualTraits = new Array<int>();
                    for (var j = 0; j < visualTraitCount; j++)
                    {
                        visualTraits.Add(buf.ReadShort());
                    }
                    properties[key] = visualTraits;
                    break;
                case NetworkedDataKey.VisualTraitColors:
                    var visualTraitColorCount = buf.ReadByte();
                    var visualTraitColors = new Array<Color>();
                    for (var j = 0; j < visualTraitColorCount; j++)
                    {
                        visualTraitColors.Add(buf.ReadColor());
                    }
                    properties[key] = visualTraitColors;
                    break;
                default:
                    throw new System.Exception("Invalid network entity data key " + key);
            }
        }
        return new NetworkedEntity
        {
            Id = id,
            Position = position,
            Direction = direction,
            IsoId = isoId,
            Properties = properties
        };
    }
    
    public void Encode(SupportedOutput buf)
    {
        buf.WriteUniqueId(System.Guid.Parse(Id));
        buf.WriteVector3Int(Position);
        buf.WriteEnum(Direction);
        buf.WriteShort((short) IsoId);
        buf.WriteByte((byte) Properties.Count);
        foreach (var (key, value) in Properties)
        {
            buf.WriteEnum(key);
            switch (key)
            {
                case NetworkedDataKey.Name:
                    buf.WriteString((string) value);
                    break;
                case NetworkedDataKey.Color:
                    buf.WriteColor((Color) value);
                    break;
                case NetworkedDataKey.Paperdolls:
                    var paperdolls = (Array) value;
                    buf.WriteByte((byte) paperdolls.Count);
                    foreach (var paperdollId in paperdolls)
                    {
                        buf.WriteShort((short) paperdollId);
                    }
                    break;
                case NetworkedDataKey.PaperdollColors:
                    var paperdollColors = (Array) value;
                    buf.WriteByte((byte) paperdollColors.Count);
                    foreach (var color in paperdollColors)
                    {
                        buf.WriteColor((Color) color);
                    }
                    break;
                case NetworkedDataKey.VisualTraits:
                    var visualTraits = (Array) value;
                    buf.WriteByte((byte) visualTraits.Count);
                    foreach (var visualTraitId in visualTraits)
                    {
                        buf.WriteShort((short) visualTraitId);
                    }
                    break;
                case NetworkedDataKey.VisualTraitColors:
                    var visualTraitColors = (Array) value;
                    buf.WriteByte((byte) visualTraitColors.Count);
                    foreach (var color in visualTraitColors)
                    {
                        buf.WriteColor((Color) color);
                    }
                    break;
                default:
                    throw new System.Exception("Invalid network data key " + key);
            }
        }
    }
    
    public override string ToString()
    {
        return $"{nameof(NetworkedEntity)}({nameof(Id)}={Id}, {nameof(Position)}={Position}, {nameof(Direction)}={Direction}, {nameof(IsoId)}={IsoId})";
    }
}