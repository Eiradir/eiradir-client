using Godot;

namespace Eiradir.registries;

public interface Registry
{
    Resource LoadEntryById(int id);
    Resource LoadEntryByName(string name);
    int GetEntryId(Resource entry);
    string GetEntryName(Resource entry);
}