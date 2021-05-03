using Godot;

public class AsepriteSprite : Sprite
{
    private AnimationPlayer _player;

    public override void _Ready()
    {
        _player = GetNode<AnimationPlayer>("AnimationPlayer");
    }

    public void Play(string name)
    {
        _player.Play(name);
    }

    public void PlayIfNew(string name)
    {
        if (_player.CurrentAnimation != name)
        {
            _player.Play(name);
        }
    }
}
