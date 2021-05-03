using System;
using System.Collections.Generic;

namespace Caracal.Scripts
{
    public abstract class State<T>
    {
        public Dictionary<string, string> Signals = new Dictionary<string, string>();

        public event Action<object, string> SignalEmitted;

        protected void Emit(string signal)
        {
            SignalEmitted?.Invoke(this, signal);
        }

        public virtual void Enter(T self)
        {
        }

        public virtual void Exit(T self)
        {
        }

        public abstract void Process(T self, float dt);
    }
}
