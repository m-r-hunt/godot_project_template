using Godot;
using Godot.Collections;

public class TiledMapLayer : TileMap
{
    [Export] public Dictionary<string, object> Properties;
    [Export] public Dictionary<int, Dictionary<string, object>> TileProperties;
}
