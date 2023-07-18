using System;
using System.Collections.Generic;
using System.IO;
using Eiradir.io;
using Eiradir.registries;

namespace Eiradir.network;

public class PacketFactory
{
    private readonly IdResolver idResolver;
    private readonly Dictionary<int, Func<SupportedInput, Packet>> packetDecoders = new();
    private readonly Dictionary<int, Action<SupportedOutput, Packet>> packetEncoders = new();
    private readonly Dictionary<int, Action<NetworkContext, Packet>> packetHandlers = new();
    private readonly Dictionary<Type, int> packetToId = new();

    public PacketFactory(IdResolver idResolver)
    {
        this.idResolver = idResolver;
    }

    private byte ComputePacketId(Type clazz)
    {
        var name = clazz.Name.Substring(0, clazz.Name.IndexOf("Packet", StringComparison.Ordinal));
        return (byte)(idResolver.Resolve("packets", name) ?? throw new ArgumentException($"Packet {name} has no id mapping"));
    }

    public void RegisterPacket<T>(Action<SupportedOutput, T> encoder, Func<SupportedInput, T> decoder) where T : Packet
    {
        int packetId = ComputePacketId(typeof(T));
        if (packetDecoders.TryGetValue(packetId, out var existing))
        {
            throw new InvalidOperationException($"Could not register {typeof(T)}: packet id {packetId} is already occupied by {existing}");
        }

        packetDecoders[packetId] = input => decoder(input);
        packetEncoders[packetId] = (output, packet) => encoder(output, (T)packet);
        packetToId[typeof(T)] = packetId;
    }

    public void RegisterPacketHandler<T>(Action<NetworkContext, T> handler) where T : Packet
    {
        var id = packetToId[typeof(T)];
        if (id == 0)
        {
            throw new InvalidOperationException($"Packet {typeof(T)} has not been registered.");
        }

        packetHandlers[id] = (context, packet) => handler(context, (T)packet);
    }

    private int GetIdForPacket(Packet packet)
    {
        var id = packetToId[packet.GetType()];
        if (id == 0)
        {
            throw new InvalidOperationException($"Packet {packet} has not been registered.");
        }

        return id;
    }

    public Action<NetworkContext, Packet> GetPacketHandler(Packet packet)
    {
        var id = GetIdForPacket(packet);
        return packetHandlers[id] ?? throw new InvalidOperationException($"No packet handler registered for packet {packet}");
    }

    public Packet ReadPacket(int id, SupportedInput buf)
    {
        return packetDecoders[id]?.Invoke(buf);
    }

    public void WritePacket(SupportedOutput buf, Packet msg)
    {
        var packetId = GetIdForPacket(msg);
        if (packetId == -1)
        {
            throw new IOException($"Packet type {msg} is not registered in the packet factory.");
        }

        buf.WriteByte(packetId);
        packetEncoders[packetId]?.Invoke(buf, msg);
    }
}