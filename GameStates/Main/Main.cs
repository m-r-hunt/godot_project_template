using System;
using Godot;

// N.b. when exporting builds, make sure stretch mode is "disabled".
// (It's nice to have it on "viewport" during development  for running non-main scenes though).

public class Main : Node2D
{
    [Export] public PackedScene InitialScene;
    private GameState _currentState;

    private Sprite _display;
    private Viewport _gameViewport;
    private Viewport _root;
    private TextureRect _bg;
    private int _gameWidth;
    private int _gameHeight;

    public override void _Ready()
    {
        _display = GetNode<Sprite>("Sprite");
        _gameViewport = GetNode<Viewport>("Viewport");
        _root = GetTree().Root;
        _bg = GetNode<TextureRect>("BG");

        _gameWidth = (int)ProjectSettings.GetSetting("display/window/size/width");
        _gameHeight = (int)ProjectSettings.GetSetting("display/window/size/height");

        _display.Position = new Vector2(_gameWidth / 2, _gameHeight / 2);

        _gameViewport.Size = new Vector2(_gameWidth, _gameHeight);

        SetupState(InitialScene);
    }

    private void SetupState(PackedScene scene)
    {
        if (_currentState != null)
        {
            _currentState.QueueFree();
        }
        _currentState = (GameState)scene.Instance();
        _gameViewport.AddChild(_currentState);
        _currentState.Connect(nameof(GameState.Transition), this, nameof(OnTransition));
        
        // Reset any wayward engine state stuff between states
        GetTree().Paused = false;
        _gameViewport.CanvasTransform = Transform2D.Identity;
    }

    private void OnTransition(PackedScene scene)
    {
        SetupState(scene);
    }

    public override void _Process(float delta)
    {
        var size = _root.Size;
        _display.Position = size / 2;

        var maxXScale = (float)Math.Floor(size.x / _gameWidth);
        var maxYScale = (float)Math.Floor(size.y / _gameHeight);
        var scale = Math.Min(maxXScale, maxYScale);
        scale = Math.Max(1, scale);
        _display.Scale = new Vector2(scale, scale);

        _bg.MarginRight = size.x;
        _bg.MarginBottom = size.y;
    }

    public override void _Input(InputEvent @event)
    {
        if (@event is InputEventMouse mouse)
        {
            mouse.Position = (mouse.Position - _display.Position + new Vector2(_gameWidth, _gameHeight) * _display.Scale / 2) / _display.Scale;
        }
        GetNode<Viewport>("Viewport").Input(@event);
    }
}
