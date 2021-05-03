using System.Collections.Generic;

namespace Caracal.Scripts
{
    public class PersistentStateManager : ISystem
    {
        private Dictionary<string, bool> _data = new Dictionary<string, bool>();
        public string CurrentPrefix = "";

        public void Reset()
        {
            _data = new Dictionary<string, bool>();
            CurrentPrefix = "";
        }

        public bool HasFlag(string path) => _data.ContainsKey(CurrentPrefix + ":" + path);

        public void SetFlag(string path, bool data)
        {
            _data[CurrentPrefix + ":" + path] = data;
        }

        public bool GetFlag(string path)
        {
            return _data[CurrentPrefix + ":" + path];
        }

        public Dictionary<string, bool> GetState()
        {
            return _data;
        }

        public void SetState(Dictionary<string, bool> state)
        {
            _data = state;
        }

        public void Free()
        {
        }
    }
}
