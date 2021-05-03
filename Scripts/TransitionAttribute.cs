using System;

namespace Caracal.Scripts
{
    [AttributeUsage(AttributeTargets.Class, AllowMultiple = true)]
    public class TransitionAttribute : Attribute
    {
        public string Signal;
        public string NewState;

        public TransitionAttribute(string signal, string newState)
        {
            Signal = signal;
            NewState = newState;
        }
    }
}
