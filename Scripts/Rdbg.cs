using System;
using System.Diagnostics;

namespace Caracal
{
    public class AssertionException : Exception
    {
        public AssertionException(string message)
            : base(message)
        {
        }
    }

    public static class Rdbg
    {
        [Conditional("DEBUG")]
        [DebuggerStepThrough]
        public static void Assert(bool condition, string message = "")
        {
            if (!condition)
            {
                throw new AssertionException(message);
            }
        }

        [Conditional("DEBUG")]
        [DebuggerStepThrough]
        public static void Unreachable(string message)
        {
            throw new AssertionException(message);
        }
    }
}
