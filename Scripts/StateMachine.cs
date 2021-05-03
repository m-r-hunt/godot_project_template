using System;
using System.Collections.Generic;
using System.Diagnostics.Contracts;
using System.Reflection;

public class StateMachine<T>
{
    public abstract class IState
    {
        public Dictionary<string, string> Signals;

        public event Action<string> SignalEmitted;

        protected void Emit(string signal)
        {
            SignalEmitted?.Invoke(signal);
        }

        public virtual void Enter(T self)
        {
            
        }

        public virtual void Exit(T self)
        {
            
        }
        
        public abstract void Process(T self, float dt);
    }

    private readonly Dictionary<string, IState> _states = new Dictionary<string, IState>();


    public string CurrentState { get; private set; }
    private readonly T _owner;
    private bool _signalled;

    public StateMachine(T owner, string current)
    {
        foreach (var t in typeof(T).GetNestedTypes(BindingFlags.NonPublic))
        {
            if (typeof(IState).IsAssignableFrom(t))
            {
                _states[t.Name] = (IState)Activator.CreateInstance(t);
                _states[t.Name].SignalEmitted += Emit;
            }
        }
        
        _owner = owner;
        CurrentState = current;
        _states[CurrentState].Enter(_owner);
    }

    private void Emit(string signal)
    {
        Contract.Assert(!_signalled);
        var c = _states[CurrentState];
        c.Exit(_owner);
        CurrentState = c.Signals[signal];
        _states[CurrentState].Enter(_owner);
        _signalled = true;
    }

    public void Process(float dt)
    {
        _signalled = false;
        _states[CurrentState].Process(_owner, dt);
    }
}
