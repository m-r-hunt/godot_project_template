using Godot;
using System;
using System.Diagnostics.Contracts;
using Godot.Collections;

public class GameState : Node
{
    [Signal]
    public delegate void Transition(PackedScene newScene);

    [Export]
    public Dictionary<string, string> Transitions;

    protected void Emit(string signal)
    {
        Contract.Assert(Transitions != null);
        Contract.Assert(!string.IsNullOrEmpty(signal) && Transitions.ContainsKey(signal), "Invalid signal");
        EmitSignal(nameof(Transition), GD.Load(Transitions[signal]));
    }
}
