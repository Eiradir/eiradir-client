using System;
using Eiradir.io;
using Godot;

namespace Eiradir.network;

public class CommandPacket : Packet
{
    private readonly string command;
    private readonly Vector3I cursorPosition;
    private readonly Guid selectedEntityId;
    
    public CommandPacket(string command, Vector3I cursorPosition, Guid selectedEntityId)
    {
        this.command = command;
        this.cursorPosition = cursorPosition;
        this.selectedEntityId = selectedEntityId;
    }
    
    public static CommandPacket Decode(SupportedInput buf)
    {
        var command = buf.ReadString();
        var cursorPosition = buf.ReadVector3Int();
        var selectedEntityId = buf.ReadUniqueId();
        return new CommandPacket(command, cursorPosition, selectedEntityId);
    }
    
    public static void Encode(SupportedOutput buf, CommandPacket packet)
    {
        buf.WriteString(packet.command);
        buf.WriteVector3Int(packet.cursorPosition);
        buf.WriteUniqueId(packet.selectedEntityId);
    }
    
    public override string ToString()
    {
        //return $"{nameof(CameraSetPositionPacket)}({nameof(Position)}={Position})";
        return $"{nameof(CommandPacket)}({nameof(command)}={command}, {nameof(cursorPosition)}={cursorPosition}, {nameof(selectedEntityId)}={selectedEntityId})";
    }
}