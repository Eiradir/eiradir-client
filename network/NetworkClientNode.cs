using System;
using System.Linq;
using DotNetty.Buffers;
using Eiradir;
using Eiradir.io;
using Godot;
using Eiradir.network;
using Eiradir.registries;
using Godot.Collections;

public partial class NetworkClientNode : Node
{
    [Signal]
    public delegate void ConnectedEventHandler();

    [Signal]
    public delegate void JoiningEventHandler();

    [Signal]
    public delegate void JoinedEventHandler();

    [Signal]
    public delegate void TileMapReceivedEventHandler();

    [Signal]
    public delegate void TileUpdateReceivedEventHandler();

    [Signal]
    public delegate void CameraPositionReceivedEventHandler();

    [Signal]
    public delegate void CameraTargetReceivedEventHandler();

    [Signal]
    public delegate void EntityReceivedEventHandler();

    [Signal]
    public delegate void EntityRemovedEventHandler();

    [Signal]
    public delegate void EntitiesReceivedEventHandler();

    [Signal]
    public delegate void EntityMovedEventHandler(string entityId, Vector3I position);

    [Signal]
    public delegate void EntityTurnedEventHandler(string entityId, GridDirection direction);

    [Signal]
    public delegate void ControlChangedEventHandler();

    [Signal]
    public delegate void HudStateReceivedEventHandler();

    [Signal]
    public delegate void HudMessageReceivedEventHandler();

    [Signal]
    public delegate void HudPropertyReceivedEventHandler();

    [Signal]
    public delegate void HudInventoryReceivedEventHandler();

    [Signal]
    public delegate void HudInventorySlotReceivedEventHandler();

    [Signal]
    public delegate void TooltipReceivedEventHandler(int nonce, Array<Dictionary<string, Variant>> items);

    [Signal]
    public delegate void MenuReceivedEventHandler(int nonce, Array<Dictionary<string, Variant>> items);

    [Signal]
    public delegate void CommandResponseReceivedEventHandler(string response);

    [Signal]
    public delegate void DisconnectedEventHandler(DisconnectPacket.DisconnectReason reason, string message);

    [ExportGroup("Network Stats")]
    [Export]
    public int Latency
    {
        get => client.Latency;
        set { }
    }

    [ExportGroup("Network Stats")]
    [Export]
    public int PacketsSentTotal
    {
        get => client.PacketsSentTotal;
        set { }
    }

    [ExportGroup("Network Stats")]
    [Export]
    public int PacketsReceivedTotal
    {
        get => client.PacketsReceivedTotal;
        set { }
    }

    [ExportGroup("Network Stats")]
    [Export]
    public int PacketsSentThisSecond
    {
        get => client.PacketsSentThisSecond;
        set { }
    }

    [ExportGroup("Network Stats")]
    [Export]
    public float PacketsSentPerSecond
    {
        get => client.PacketsSentPerSecond;
        set { }
    }

    [ExportGroup("Network Stats")]
    [Export]
    public int PacketsReceivedThisSecond
    {
        get => client.PacketsReceivedThisSecond;
        set { }
    }

    [ExportGroup("Network Stats")]
    [Export]
    public float PacketsReceivedPerSecond
    {
        get => client.PacketsReceivedPerSecond;
        set { }
    }

    private NetworkClient client;
    private RegistriesImpl registries;

    public NetworkClientNode()
    {
        var staticIdMappingsResolver = new StaticIdMappingsResolver().LoadFromResources();
        var packetFactory = new PacketFactory(staticIdMappingsResolver);
        client = new NetworkClient(packetFactory, registries = new RegistriesImpl());
        // TODO eventBus.post(NetworkRegisterPacketsEvent(packetFactory))
        // TODO eventBus.post(NetworkRegisterHandlersEvent(packetFactory))

        packetFactory.RegisterPacket(ConnectPacket.Encode, ConnectPacket.Decode);
        packetFactory.RegisterPacket(ConnectionStatusPacket.Encode, ConnectionStatusPacket.Decode);
        packetFactory.RegisterPacket(DisconnectPacket.Encode, DisconnectPacket.Decode);
        packetFactory.RegisterPacket(TileMapPacket.Encode, TileMapPacket.Decode);
        packetFactory.RegisterPacket(TileUpdatePacket.Encode, TileUpdatePacket.Decode);
        packetFactory.RegisterPacket(CameraSetPositionPacket.Encode, CameraSetPositionPacket.Decode);
        packetFactory.RegisterPacket(CameraFollowEntityPacket.Encode, CameraFollowEntityPacket.Decode);
        packetFactory.RegisterPacket(CommandPacket.Encode, CommandPacket.Decode);
        packetFactory.RegisterPacket(CommandResponsePacket.Encode, CommandResponsePacket.Decode);
        packetFactory.RegisterPacket(EntityAddPacket.Encode, EntityAddPacket.Decode);
        packetFactory.RegisterPacket(EntityRemovePacket.Encode, EntityRemovePacket.Decode);
        packetFactory.RegisterPacket(EntitiesAddPacket.Encode, EntitiesAddPacket.Decode);
        packetFactory.RegisterPacket(ControllerPacket.Encode, ControllerPacket.Decode);
        packetFactory.RegisterPacket(HudStatePacket.Encode, HudStatePacket.Decode);
        packetFactory.RegisterPacket(HudMessagePacket.Encode, HudMessagePacket.Decode);
        packetFactory.RegisterPacket(HudPropertyPacket.Encode, HudPropertyPacket.Decode);
        packetFactory.RegisterPacket(HudInventoryPacket.Encode, HudInventoryPacket.Decode);
        packetFactory.RegisterPacket(HudInventorySlotPacket.Encode, HudInventorySlotPacket.Decode);
        packetFactory.RegisterPacket(HudInventorySlotInteractPacket.Encode, HudInventorySlotInteractPacket.Decode);
        packetFactory.RegisterPacket(InteractPacket.Encode, InteractPacket.Decode);
        packetFactory.RegisterPacket(TileInteractPacket.Encode, TileInteractPacket.Decode);
        packetFactory.RegisterPacket(EntityInteractPacket.Encode, EntityInteractPacket.Decode);
        packetFactory.RegisterPacket(TooltipPacket.Encode, TooltipPacket.Decode);
        packetFactory.RegisterPacket(MenuPacket.Encode, MenuPacket.Decode);
        packetFactory.RegisterPacket(EntityMovePacket.Encode, EntityMovePacket.Decode);
        packetFactory.RegisterPacket(EntityDirectionPacket.Encode, EntityDirectionPacket.Decode);
        packetFactory.RegisterPacket(MoveInputPacket.Encode, MoveInputPacket.Decode);
        packetFactory.RegisterPacket(TurnInputPacket.Encode, TurnInputPacket.Decode);
        
        packetFactory.RegisterPacketHandler<ConnectionStatusPacket>((context, packet) =>
        {
            switch (packet.Status)
            {
                case ConnectionStatusPacket.ConnectionStatus.LOADING:
                    EmitSignal(SignalName.Joining);
                    break;
                case ConnectionStatusPacket.ConnectionStatus.COMPLETE:
                    EmitSignal(SignalName.Joined);
                    break;
                default:
                    GD.Print($"Unhandled connection status {packet.Status}");
                    break;
            }
        });
        packetFactory.RegisterPacketHandler<DisconnectPacket>((context, packet) => EmitSignal(SignalName.Disconnected, (int) packet.Reason, packet.Message));
        packetFactory.RegisterPacketHandler<TileMapPacket>((context, packet) =>
            EmitSignal(SignalName.TileMapReceived, packet.Name, packet.ChunkPos, packet.ChunkSize, packet.Tiles));
        packetFactory.RegisterPacketHandler<TileUpdatePacket>((context, packet) =>
            EmitSignal(SignalName.TileUpdateReceived, packet.MapName, packet.Position, packet.TileId));
        packetFactory.RegisterPacketHandler<CameraSetPositionPacket>((context, packet) => EmitSignal(SignalName.CameraPositionReceived, packet.Position));
        packetFactory.RegisterPacketHandler<CameraFollowEntityPacket>((context, packet) =>
            EmitSignal(SignalName.CameraTargetReceived, packet.EntityId.ToString()));
        packetFactory.RegisterPacketHandler<CommandResponsePacket>((context, packet) => EmitSignal(SignalName.CommandResponseReceived, packet.Response));
        packetFactory.RegisterPacketHandler<EntitiesAddPacket>((context, packet) =>
            EmitSignal(SignalName.EntitiesReceived, packet.MapName, packet.ChunkPos, packet.Entities));
        packetFactory.RegisterPacketHandler<EntityAddPacket>((context, packet) => EmitSignal(SignalName.EntityReceived, packet.MapName, packet.Entity));
        packetFactory.RegisterPacketHandler<EntityRemovePacket>((context, packet) =>
            EmitSignal(SignalName.EntityRemoved, packet.MapName, packet.EntityId.ToString()));
        packetFactory.RegisterPacketHandler<ControllerPacket>((context, packet) =>
            EmitSignal(SignalName.ControlChanged, packet.EntityId.ToString(), (int)packet.Type, packet.Seat));
        packetFactory.RegisterPacketHandler<HudStatePacket>((context, packet) =>
            EmitSignal(SignalName.HudStateReceived, packet.HudId, packet.TypeId, (int)packet.State));
        packetFactory.RegisterPacketHandler<HudMessagePacket>((context, packet) =>
            EmitSignal(SignalName.HudMessageReceived, packet.HudId, packet.Key, new GodotSupportedByteBuffer(packet.Data, registries)));
        packetFactory.RegisterPacketHandler<HudPropertyPacket>((context, packet) =>
            EmitSignal(SignalName.HudPropertyReceived, packet.HudId, packet.Key, new GodotSupportedByteBuffer(packet.Data, registries)));
        packetFactory.RegisterPacketHandler<HudInventoryPacket>((context, packet) =>
            EmitSignal(SignalName.HudInventoryReceived, packet.HudId, packet.Key, packet.Items));
        packetFactory.RegisterPacketHandler<HudInventorySlotPacket>((context, packet) =>
            EmitSignal(SignalName.HudInventorySlotReceived, packet.HudId, packet.Key, packet.SlotId, packet.Item));
        packetFactory.RegisterPacketHandler<TooltipPacket>((context, packet) => EmitSignal(SignalName.TooltipReceived, packet.Nonce, packet.Items));
        packetFactory.RegisterPacketHandler<MenuPacket>((context, packet) => EmitSignal(SignalName.MenuReceived, packet.Nonce, packet.Items));
        packetFactory.RegisterPacketHandler<EntityMovePacket>((context, packet) =>
            EmitSignal(SignalName.EntityMoved, packet.EntityId.ToString(), packet.Position));
        packetFactory.RegisterPacketHandler<EntityDirectionPacket>((context, packet) =>
            EmitSignal(SignalName.EntityTurned, packet.EntityId.ToString(), (int) packet.Direction));
    }

    public override void _Ready()
    {
        registries.Load(this);
    }

    public override void _Process(double delta)
    {
        client.ProcessPackets();
    }

    public async void ConnectToServer(string host, int port)
    {
        await client.Connect(host, port);
        EmitSignal(SignalName.Connected);
    }

    public void SendConnect(string username, string joinToken, Godot.Collections.Dictionary properties)
    {
        var props = properties.ToDictionary(it => it.Key.AsString(), it => it.Value.AsString());
        client.Send(new ConnectPacket(username, joinToken, props));
    }

    public void SendCommand(string command, Vector3I cursorPosition, string selectedEntityId)
    {
        client.Send(new CommandPacket(command, cursorPosition,
            selectedEntityId != null && selectedEntityId.Length > 0 ? Guid.Parse(selectedEntityId) : Guid.Empty));
    }

    public void SendCameraPosition(Vector3I position)
    {
        client.Send(new CameraSetPositionPacket(position));
    }

    public void SendHudMessage(Node message, Variant value)
    {
        var data = Unpooled.Buffer();
        var buf = new GodotSupportedByteBuffer(data, registries);
        var hudId = message.Get("hud_id").AsInt32();
        var key = message.Get("key").AsInt32();
        message.Call("encode", value, buf);
        client.Send(new HudMessagePacket(hudId, key, data));
    }

    public void SendHudProperty(Node property)
    {
        var data = Unpooled.Buffer();
        var buf = new GodotSupportedByteBuffer(data, registries);
        var hudId = property.Get("hud_id").AsInt32();
        var key = property.Get("key").AsInt32();
        property.Call("encode", buf);
        client.Send(new HudPropertyPacket(hudId, key, data));
    }

    public void SendHudInventorySlotInteract(int hudId, int key, int slotId, int interactionId)
    {
        client.Send(new HudInventorySlotInteractPacket(hudId, key, slotId, interactionId, Unpooled.Empty));
    }

    public void SendHudInventorySlotInteractI(int hudId, int key, int slotId, int interactionId, int param)
    {
        var data = Unpooled.Buffer(4);
        data.WriteInt(param);
        client.Send(new HudInventorySlotInteractPacket(hudId, key, slotId, interactionId, data));
    }

    public void SendInteract(int interactionId)
    {
        client.Send(new InteractPacket(interactionId, Unpooled.Empty));
    }

    public void SendTileInteract(Vector2I mapPosition, int level, int interactionId, Array<Variant> args)
    {
        client.Send(new TileInteractPacket(new Vector3I(mapPosition.X, mapPosition.Y, level), interactionId, EncodeInteractionParams(args)));
    }

    public void SendEntityInteract(string entityId, int interactionId, Array<Variant> args)
    {
        client.Send(new EntityInteractPacket(Guid.Parse(entityId), interactionId, EncodeInteractionParams(args)));
    }

    public void SendMoveInput(Vector3I position)
    {
        client.Send(new MoveInputPacket(position));
    }
    
    public void SendTurnInput(GridDirection direction)
    {
        client.Send(new TurnInputPacket(direction));
    }

    private IByteBuffer EncodeInteractionParams(Array<Variant> args)
    {
        var data = args.Count == 0 ? Unpooled.Empty : Unpooled.Buffer();
        foreach (var arg in args)
        {
            switch (arg.VariantType)
            {
                case Variant.Type.Int:
                    data.WriteInt(arg.AsInt32());
                    break;
                default:
                    throw new ArgumentOutOfRangeException(arg.ToString());
            }
        }

        return data;
    }
}