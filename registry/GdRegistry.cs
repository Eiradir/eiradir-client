using Godot;

namespace Eiradir.registries;

public class GdRegistry : Registry
{
    private readonly GodotObject registry;
    
    public GdRegistry(GodotObject registry)
    {
        this.registry = registry;
    }

    public Resource LoadEntryById(int id)
    {
        return registry.Call("load_entry_by_id", id).AsGodotObject() as Resource;
    }
    
    public Resource LoadEntryByName(string name)
    {
        return registry.Call("load_entry_by_name", name).AsGodotObject() as Resource;
    }
    
    public int GetEntryId(Resource entry)
    {
        return (int) registry.Call("get_entry_id", entry);
    }
    
    public string GetEntryName(Resource entry)
    {
        return (string) registry.Call("get_entry_name", entry);
    }
}