using Godot;

namespace Caracal.Scripts
{
    public interface ISystem
    {
        void Reset();

        void Free();
    }

    public class Systems : Node
    {
        private static Systems _instance;
        public GenericStorage<ISystem> Storage = new GenericStorage<ISystem>();

        public override void _EnterTree()
        {
            _instance = this;
            Reset();
        }

        public override void _ExitTree()
        {
            foreach (var sys in Storage)
            {
                sys.Free();
            }
        }

        public void Reset()
        {
            foreach (var sys in Storage)
            {
                sys.Reset();
            }
        }

        public static Systems Instance => _instance;
    }
}
