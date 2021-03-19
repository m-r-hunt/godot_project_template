using Godot;
using System;

public class Gameplay : GameState
{
    public void OnFinishClicked()
    {
        Emit("GameOver");
    }
}
