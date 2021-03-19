using Godot;
using System;

public class Credits : GameState
{
    public void OnFinishClicked()
    {
        Emit("Finished");
    }
}
