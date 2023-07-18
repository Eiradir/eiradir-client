namespace Eiradir.registries;

public interface IdResolver
{
    int? Resolve(string registryName, string name);
}