# Pharaoh Modding - Quick Start Guide

## Getting Started

This guide will help you quickly set up and start developing mods for Pharaoh: A New Era using BepInEx.

### Step 1: Prerequisites

Make sure you have the following installed:
- Visual Studio Code
- .NET SDK (supports .NET Framework 4.7.2)
- Git (optional, for version control)
- Pharaoh: A New Era installed with BepInEx 5.x
- dnSpy (for decompiling game assemblies)

### Step 2: Clone or Download the Repository

If using Git:
```
git clone https://github.com/MrPurple6411/Pharaoh.git
cd Pharaoh
```

Or download and extract the repository as a ZIP file.

### Step 3: Set Up Your Game Path

1. Make sure `GamePath.props` exists in the repository root
2. Verify it contains the correct path to your game installation:

```xml
<Project>
  <PropertyGroup>
    <GamePath>C:\Program Files (x86)\Steam\steamapps\common\Pharaoh A New Era</GamePath>
  </PropertyGroup>
</Project>
```

Update the path if necessary to match your installation.

### Step 4: Decompile Game Code

Since the decompiled game code is not included in the repository, you'll need to generate it yourself:

1. Download dnSpy from [GitHub Releases](https://github.com/dnSpy/dnSpy/releases)
2. Launch dnSpy and open the Assembly-CSharp.dll from your game:
   - File → Open
   - Navigate to: `[GamePath]\Pharaoh_Data\Managed\Assembly-CSharp.dll`
3. Export the decompiled code:
   - Go to File → Export to Project...
   - Choose C# language
   - Set the output directory to the `Assembly-CSharp` folder in your repository
   - Click OK and wait for the export to complete

This will create all the necessary .cs files that you can use as reference for understanding the game's code.

### Step 5: Open in Visual Studio Code

1. Launch Visual Studio Code
2. Open the repository folder (File → Open Folder)
3. Install recommended extensions if prompted

### Step 6: Create Your First Mod

1. Create a new folder for your mod in the repository root, e.g., `MyFirstMod`
2. Create a basic .csproj file in this folder:

```xml
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <AssemblyName>MyFirstMod</AssemblyName>
    <BepInExPluginName>My First Pharaoh Mod</BepInExPluginName>
    <Description>My first mod for Pharaoh</Description>
    <Version>1.0.0</Version>
    <RootNamespace>MyFirstMod</RootNamespace>
  </PropertyGroup>
</Project>
```

3. Add the project to the solution:
   - Open a terminal in VS Code (Terminal → New Terminal)
   - Run: `dotnet sln add MyFirstMod/MyFirstMod.csproj`

4. Create a `Plugin.cs` file with this template:

```csharp
using BepInEx;
using BepInEx.Logging;
using UnityEngine;

namespace MyFirstMod
{
    [BepInPlugin(MyPluginInfo.PLUGIN_GUID, MyPluginInfo.PLUGIN_NAME, MyPluginInfo.PLUGIN_VERSION)]
    public class Plugin : BaseUnityPlugin
    {
        private readonly ManualLogSource _logger;

        public Plugin()
        {
            _logger = Logger;
        }

        private void Awake()
        {
            _logger.LogInfo($"Plugin {MyPluginInfo.PLUGIN_NAME} is loaded!");
            // Your code here
        }
    }
}
```

### Step 7: Build Your Mod

1. Build the solution:
   - Using VS Code UI: Press Ctrl+Shift+B and select the build task
   - Or using terminal: `dotnet build -c Release`

2. Find your outputs:
   - Built DLL: `bin\Release\MyFirstMod\`
   - Packaged mod: `Zips_Release\MyFirstMod_Release_v1.0.0.zip`

### Step 8: Test Your Mod

1. Install your mod by extracting the ZIP file into your BepInEx installation
   - Or copy the built DLL to `[Pharaoh installation]\BepInEx\plugins\MyFirstMod\`

2. Launch the game and check if your mod loads
   - Look for your mod's messages in the BepInEx console or log file

### Step 9: Develop Your Mod

Explore the game's code in the `Assembly-CSharp` project to understand:
- How game systems work
- Which methods to hook with Harmony for your mod
- How to interact with game objects and components

Use the `TECHNICAL_REFERENCE.md` document for advanced modding techniques.

## Useful Development Tips

- **Exploring Game Methods**: Use the decompiled `Assembly-CSharp` code to find methods you want to modify
- **Testing Changes**: For faster iteration, consider setting up a symlink from your build output to the BepInEx plugins folder
- **Debugging**: Use BepInEx's logging and configuration systems to help debug your mod
- **Harmony Patches**: Use Harmony to modify game behavior without editing original files

## Next Steps

- Review the `PROJECT_OVERVIEW.md` document for a comprehensive overview
- Read the `TECHNICAL_REFERENCE.md` document for advanced topics
- Consider contributing to the modding documentation to help others
- Join modding communities for Pharaoh: A New Era to share your work and get help

## Additional Resources

- BepInEx Documentation: https://bepinex.github.io/bepinex_docs/master/index.html
- Harmony Wiki: https://harmony.pardeike.net/articles/intro.html
- Unity Scripting API (2019.4): https://docs.unity3d.com/2019.4/Documentation/ScriptReference/
