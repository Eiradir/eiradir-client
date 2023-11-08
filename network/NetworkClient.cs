using System;
using System.Collections.Concurrent;
using System.Net;
using System.Threading;
using System.Threading.Tasks;
using DotNetty.Codecs;
using DotNetty.Handlers.Timeout;
using DotNetty.Transport.Bootstrapping;
using DotNetty.Transport.Channels;
using DotNetty.Transport.Channels.Local;
using DotNetty.Transport.Channels.Sockets;
using Eiradir.network;
using Eiradir.registries;
using static Godot.GD;

public class NetworkClient : ChannelHandlerAdapter, NetworkContext
{
    private readonly PacketFactory packetFactory;
    private readonly Registries registries;

    private const int networkReadTimeout = 60000;
    private const int maxFrameLength = short.MaxValue;
    private const int lengthFieldLength = 2;

    private readonly ConcurrentQueue<Packet> incomingPackets = new();
    
    public int PacketsSentTotal { get; private set; }
    public int PacketsReceivedTotal { get; private set; }
    public int PacketsSentThisSecond { get; private set; }
    public float PacketsSentPerSecond { get; private set; }
    public int PacketsReceivedThisSecond { get; private set; }
    public float PacketsReceivedPerSecond { get; private set; }
    public int Latency { get; private set; }

    private readonly MultithreadEventLoopGroup workerGroup = new(1);
    private readonly Bootstrap bootstrap;
    private int timeSinceLastSecond;

    public IChannel Channel { get; private set; } = new LocalChannel();
    public EndPoint Address => Channel.RemoteAddress;
    public bool IsConnected => Channel.Registered && Channel.Active;

    public override bool IsSharable => true;

    public NetworkClient(PacketFactory packetFactory, Registries registries)
    {
        this.packetFactory = packetFactory;
        this.registries = registries;

        packetFactory.RegisterPacket(PingPacket.Encode, PingPacket.Decode);
        packetFactory.RegisterPacketHandler<PingPacket>(HandlePingPacket);

        bootstrap = new Bootstrap().Group(workerGroup)
            .Channel<TcpSocketChannel>()
            .Option(ChannelOption.SoKeepalive, true)
            .Handler(new ActionChannelInitializer<ISocketChannel>(channel =>
            {
                channel.Pipeline
                    .AddLast(new ReadTimeoutHandler(networkReadTimeout))
                    .AddLast("frameDecoder",
                        new LengthFieldBasedFrameDecoder(maxFrameLength, 0, lengthFieldLength, 0, lengthFieldLength))
                    .AddLast("decoder", new PacketDecoder(packetFactory, registries))
                    .AddLast("packetHandler", this)
                    .AddLast("framePrepender", new LengthFieldPrepender(lengthFieldLength))
                    .AddLast("encoder", new PacketEncoder(packetFactory, registries));
            }));
    }

    public async Task<IChannel> Connect(string host, int port)
    {
        var channel = await bootstrap.ConnectAsync(host, port);
        Channel = channel;
        Print("Connected to ", host, ":", port);
        Thread thread = new Thread(() =>
        {
            var last = DateTime.Now.Ticks / TimeSpan.TicksPerMillisecond;
            while (!workerGroup.IsShutdown)
            {
                var now = DateTime.Now.Ticks / TimeSpan.TicksPerMillisecond;
                var delta = (int)(now - last);
                last = now;

                UpdateStatistics(delta);
                //ProcessPackets();

                Thread.Sleep(10);
            }
        });

        thread.Name = "NetworkClient";
        thread.Start();
        return channel;
    }

    private void UpdateStatistics(int delta)
    {
        timeSinceLastSecond += delta;
        if (timeSinceLastSecond >= 1000)
        {
            timeSinceLastSecond = 0;
            PacketsSentPerSecond = (PacketsSentPerSecond * 0.9f) + (PacketsSentThisSecond * 0.1f);
            PacketsReceivedPerSecond = (PacketsReceivedPerSecond * 0.9f) + (PacketsReceivedThisSecond * 0.1f);
            PacketsSentThisSecond = 0;
            PacketsReceivedThisSecond = 0;
        }
    }

    public void ProcessPackets()
    {
        while (incomingPackets.TryDequeue(out var packet))
        {
            var handler = packetFactory.GetPacketHandler(packet);
            // if (packet is not PingPacket)
            // {
            //     Print($"Received packet {packet}");
            // }

            handler(this, packet);
        }
    }

    public override void ExceptionCaught(IChannelHandlerContext context, Exception exception)
    {
        base.ExceptionCaught(context, exception);
        Print("Network error", exception);
#pragma warning disable CS4014
        Disconnect();
#pragma warning restore CS4014
    }

    public override void ChannelInactive(IChannelHandlerContext context)
    {
        base.ChannelInactive(context);
        Print("Disconnected from server");
        // eventBus.post(ClientConnectionClosedEvent())
    }

    public override void ChannelRead(IChannelHandlerContext context, object message)
    {
        PacketsReceivedTotal++;
        PacketsReceivedThisSecond++;
        incomingPackets.Enqueue(message as Packet);
    }

    public async Task Disconnect()
    {
        await Channel.CloseAsync();
    }

    public async Task Stop()
    {
        await Disconnect();
        await workerGroup.ShutdownGracefullyAsync();
    }

    public async Task Respond(Packet packet)
    {
        await Send(packet);
    }

    public async Task Send(Packet packet)
    {
        PacketsSentTotal++;
        PacketsSentThisSecond++;
        await Channel.WriteAndFlushAsync(packet);
    }

    private void HandlePingPacket(NetworkContext context, PingPacket packet)
    {
        context.Respond(packet);
        Latency = packet.lastLatency;
    }
}