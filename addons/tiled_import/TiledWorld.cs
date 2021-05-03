using Godot;
using Godot.Collections;

public class TiledWorld : Resource
{
    [Export] public Array<MapDescriptor> Maps;

    public MapDescriptor MapAtPosition(Vector2 pos)
    {
        foreach (var m in Maps)
        {
            if (m.PointInside(pos))
            {
                return m;
            }
        }
        return null;
    }
}
