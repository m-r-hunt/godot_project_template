using Godot;
using Godot.Collections;

public class TiledMap : Node2D
{
    [Export] public Dictionary<string, object> Properties;
    [Export] public Dictionary<int, Dictionary<string, object>> TileProperties;
}
