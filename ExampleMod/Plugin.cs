using BepInEx;
using BepInEx.Logging;
using System;
using UnityEngine;

namespace ExampleMod
{
    [BepInPlugin(MyPluginInfo.PLUGIN_GUID, MyPluginInfo.PLUGIN_NAME, MyPluginInfo.PLUGIN_VERSION)]
    public class Plugin : BaseUnityPlugin
    {
        // Create a logger instance for your plugin
        internal static ManualLogSource Log;

        private void Awake()
        {
            // Plugin startup logic
            Log = Logger;
            Log.LogInfo($"Plugin {MyPluginInfo.PLUGIN_GUID} is loaded!");

            // Add your plugin initialization logic here
            // Example: Harmony.CreateAndPatchAll(typeof(Plugin).Assembly);
        }
    }
}
