using Godot;

public class MapDescriptor : Resource
{
    [Export] public string MapPath;
    [Export] public int X;
    [Export] public int Y;
    [Export] public int Width;
    [Export] public int Height;

    public bool PointInside(Vector2 pos)
    {
        return pos.x >= X && pos.x < X + Width && pos.y >= Y && pos.y < Y + Height;
    }
}
