using Godot;
using System;

[Tool]
public class Button : Node2D
{
    private const string _buttonNodeName = "ActualButton";
    
    [Signal]
    delegate void Pressed();

    private string _text;
    
    [Export]
    public string Text
    {
        get => _text;
        set
        {
            _text = value;
            if (GetNodeOrNull(_buttonNodeName) is Godot.Button button)
            {
                button.Text = _text ?? "";
            }
        }
    }

    public override void _Ready()
    {
        GetNode<Godot.Button>(_buttonNodeName).Text = _text ?? "";
    }

    public void OnActualButtonPressed()
    {
        EmitSignal(nameof(Pressed));
    }
}
