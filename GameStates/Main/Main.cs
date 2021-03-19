using Godot;
using System;

public class Main : Node2D
{
    [Export] public PackedScene InitialScene;
    private GameState _currentState;

    // Called when the node enters the scene tree for the first time.
    public override void _Ready()
    {
        SetupState(InitialScene);
    }

    private void SetupState(PackedScene scene)
    { 
        if (_currentState != null)
        {
            RemoveChild(_currentState);
        }
        _currentState = scene.Instance() as GameState;
        AddChild(_currentState);
        _currentState.Connect(nameof(GameState.Transition), this, nameof(OnTransition));
    }

    private void OnTransition(PackedScene scene)
    {
        SetupState(scene);
    }

//  // Called every frame. 'delta' is the elapsed time since the previous frame.
//  public override void _Process(float delta)
//  {
//      
//  }
}
