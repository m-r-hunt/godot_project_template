using System;
using System.Collections;
using System.Collections.Generic;

namespace Caracal.Scripts
{
    /// <summary>
    /// Stores objects implementing a specific interface, indexed by type.
    /// </summary>
    /// <remarks>
    /// Only uses exact concrete type matching, doesn't consider e.g. inheritance.
    /// </remarks>
    /// <typeparam name="TInterface">Interface type to be stored</typeparam>
    public class GenericStorage<TInterface> : IEnumerable<TInterface>
        where TInterface : class
    {
        private readonly Dictionary<Type, TInterface> _storage;

        /// <summary>
        /// Default constructor. Constructs empty storage.
        /// </summary>
        public GenericStorage()
        {
            _storage = new Dictionary<Type, TInterface>();
        }

        /// <summary>
        ///  Returns an existing object, or null if not present in storage.
        /// </summary>
        /// <typeparam name="TConcrete">Concrete type implementing TInterface</typeparam>
        /// <returns>Stored TConcrete object or null</returns>
        public TConcrete Get<TConcrete>()
            where TConcrete : class, TInterface
        {
            var found = _storage.TryGetValue(typeof(TConcrete), out var ret);
            return found ? (TConcrete)ret : null;
        }

        /// <summary>
        /// Return an existing object if found, or add and return a new default-constructed copy.
        /// </summary>
        /// <typeparam name="TConcrete">Default constructable concrete type implementing TInterface</typeparam>
        /// <returns>Stored TConcrete object</returns>
        public TConcrete GetOrDefault<TConcrete>()
            where TConcrete : class, TInterface, new()
        {
            var existing = Get<TConcrete>();
            if (existing == null)
            {
                existing = new TConcrete();
                Add(existing);
            }
            return existing;
        }

        /// <summary>
        /// Insert an object into storage.
        /// </summary>
        /// <param name="value"></param>
        public void Add(TInterface value)
        {
            _storage[value.GetType()] = value;
        }

        public IEnumerator<TInterface> GetEnumerator()
        {
            return _storage.Values.GetEnumerator();
        }

        IEnumerator IEnumerable.GetEnumerator()
        {
            return _storage.Values.GetEnumerator();
        }
    }
}
