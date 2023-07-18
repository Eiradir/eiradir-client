using System;
using Godot;

namespace Eiradir.registries;

public class RegistriesImpl : Registries
{
    public Registry Tiles { get; private set; }

    public void Load(Node node)
    {
        var registries = node.GetNode("/root/Registries");
        Tiles = new GdRegistry(registries.Get("tiles").AsGodotObject());
    }

    public Registry GetRegistry(string registry)
    {
        return registry switch
        {
            "tiles" => Tiles,
            _ => throw new ArgumentException($"Unknown registry {registry}")
        };
    }
}