using System.Collections.Generic;
using Godot;

namespace Caracal.Scripts
{
    public static class NodeExtensions
    {
        public static void RemoveFromParent(this Node @this) => @this.GetParent().RemoveChild(@this);

        public static IEnumerable<Node> GetChildNodes(this Node @this)
        {
            foreach (var o in @this.GetChildren())
            {
                yield return (Node)o;
            }
        }

        public static IEnumerable<TNode> GetChildNodes<TNode>(this Node @this) where TNode : Node
        {
            foreach (var o in @this.GetChildren())
            {
                if (o is TNode tn)
                {
                    yield return tn;
                }
            }
        }
    }
}
