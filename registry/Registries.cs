namespace Eiradir.registries;

public interface Registries
{
    public static string TILES = "tiles";
    
    Registry Tiles { get; }

    Registry GetRegistry(string registry);
}