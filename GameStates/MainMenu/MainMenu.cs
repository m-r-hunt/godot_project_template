using Godot;
using System;

public class MainMenu : GameState
{
    public void OnPlayClicked()
    {
        Emit("Play");
    }

    public void OnCreditsClicked()
    {
        Emit("Credits");
    }

    public void OnQuitClicked()
    {
        GetTree().Quit();
    }
}
