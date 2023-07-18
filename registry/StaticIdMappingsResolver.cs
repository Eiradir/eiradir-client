using Godot;

namespace Eiradir.registries;

using System.Collections.Generic;

public class StaticIdMappingsResolver : IdResolver
{
    public struct RegistryId
    {
        public string Registry;
        public int Id;

        public RegistryId(string registry, int id)
        {
            Registry = registry;
            Id = id;
        }
    }

    public struct RegistryKey
    {
        public string Registry;
        public string Key;

        public RegistryKey(string registry, string key)
        {
            Registry = registry;
            Key = key;
        }
    }

    private readonly Dictionary<RegistryId, string> idToKeyMappings = new();
    private readonly Dictionary<RegistryKey, int> keyToIdMappings = new();

    public StaticIdMappingsResolver LoadFromResources(string path = "res://id_mappings.ini")
    {
        var file = new ConfigFile();
        file.Load(path);
        foreach (var registry in file.GetSections())
        {
            foreach (var id in file.GetSectionKeys(registry))
            {
                var key = file.GetValue(registry, id).AsString();
                idToKeyMappings[new RegistryId(registry, int.Parse(id))] = key;
                keyToIdMappings[new RegistryKey(registry, key)] = int.Parse(id);
            }
        }
        return this;
    }
    public int? Resolve(string registryName, string name)
    {
        var key = new RegistryKey(registryName, name);
        return keyToIdMappings.TryGetValue(key, out var id) ? id : null;
    }
}