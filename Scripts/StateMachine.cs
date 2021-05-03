using System;
using System.Collections.Generic;
using System.Diagnostics.Contracts;
using System.Reflection;
using Godot;

namespace Caracal.Scripts
{
    public class StateMachine<T> : StateMachine<T, State<T>>
    {
        public StateMachine(T owner, string current)
            : base(owner, current)
        {
        }
    }

    public class StateMachine<T, TState>
        where TState : State<T>
    {
        private readonly Dictionary<string, TState> _states = new Dictionary<string, TState>();

        public string CurrentState { get; set; }
        public TState Current => _states[CurrentState];
        private readonly T _owner;
        private bool _signalled;

        public StateMachine(T owner, string current)
        {
            foreach (var t in typeof(T).GetNestedTypes(BindingFlags.NonPublic))
            {
                if (typeof(TState).IsAssignableFrom(t))
                {
                    _states[t.Name] = (TState)Activator.CreateInstance(t);
                    _states[t.Name].SignalEmitted += Emit;

                    foreach (var attr in t.GetCustomAttributes<TransitionAttribute>())
                    {
                        _states[t.Name].Signals[attr.Signal] = attr.NewState;
                    }
                }
            }

            _owner = owner;
            CurrentState = current;
            _states[CurrentState].Enter(_owner);
        }

        private void Emit(object sender, string signal)
        {
            if (sender != _states[CurrentState])
            {
                GD.PushWarning("Signal emitted by inactive state");
                return;
            }

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
            _signalled = false;
        }
    }
}
