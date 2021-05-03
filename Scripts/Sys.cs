namespace Caracal.Scripts
{
    public static class Sys
    {
        public static PersistentStateManager PersistentStateManager => Systems.Instance.Storage.GetOrDefault<PersistentStateManager>();

        public static EventBus EventBus => Systems.Instance.Storage.GetOrDefault<EventBus>();
    }
}
