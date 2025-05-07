# Pharaoh Modding Workspace

## Overview
This repository contains a unified Visual Studio Code workspace for developing BepInEx mods for Pharaoh: A New Era (Unity 2019.4.38). The workspace is structured to minimize redundancy in project files, with most configuration settings centralized in the Directory.Build.props and Directory.Build.targets files.

## Repository Structure
- `Directory.Build.props`: Central configuration file for all projects in the solution
- `Directory.Build.targets`: Build automation for packaging mods into BepInEx-compatible zip files
- `GamePath.props`: Contains the path to your Pharaoh installation (excluded from git via .gitignore)
- `Assembly-CSharp/`: Decompiled game code used as reference for modding (not included in git repository)
- `PharaohMod/`: Template mod project with minimal .csproj configuration
- `bin/`: Build output folder for all mod projects

## Technical Details
- **Target Framework**: .NET Framework 4.7.2 (net472)
- **Unity Version**: 2019.4.38
- **BepInEx Version**: 5.x
- **Project Structure**:
  - Simplified .csproj files for each mod
  - Centralized references and build configuration
  - Automated mod packaging via MSBuild targets

## How to Use This Repository

### Prerequisites
- Visual Studio Code with C# extension
- .NET SDK
- BepInEx 5.x installed in your Pharaoh: A New Era game directory
- dnSpy for decompiling game assemblies

### Setting Up
1. Clone this repository
2. Create or verify `GamePath.props` points to your Pharaoh installation:
   ```xml
   <Project>
     <PropertyGroup>
       <GamePath>C:\Program Files (x86)\Steam\steamapps\common\Pharaoh A New Era</GamePath>
     </PropertyGroup>
   </Project>
   ```
3. Decompile the game code using dnSpy (see "Decompiling Game Code" section below)
4. Open the workspace in Visual Studio Code

### Creating a New Mod
1. Create a new folder in the repository root with your mod name
2. Add a minimal .csproj file:
   ```xml
   <Project Sdk="Microsoft.NET.Sdk">
     <PropertyGroup>
       <AssemblyName>YourModName</AssemblyName>
       <BepInExPluginName>Your Mod Display Name With Spaces</BepInExPluginName>
       <Description>Description of your mod</Description>
       <Version>1.0.0</Version>
       <RootNamespace>YourModName</RootNamespace>
     </PropertyGroup>
   </Project>
   ```
3. Create a `Plugin.cs` file with BepInEx plugin structure:
   ```csharp
   using BepInEx;
   using BepInEx.Logging;
   using UnityEngine;

   namespace YourModName
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
           }
       }
   }
   ```
4. Add the project to the solution in Visual Studio Code

### Building Your Mod
Build your mod through Visual Studio Code or with the following command:
```
dotnet build -c Release
```

The built mod will be placed in `bin\Release\YourModName\` and a ready-to-install zip file will be created in the `Zips_Release` folder at the solution root.

### Referencing Game Code
All necessary game assemblies are referenced in `Directory.Build.props`:
- Assembly-CSharp.dll
- UnityEngine.dll and its modules
- Other game-specific libraries

You can extend these references in your mod's .csproj file if additional dependencies are needed.

## Using the Assembly-CSharp Reference
The `Assembly-CSharp` project contains the decompiled game code for reference. Use it to:
1. Understand game mechanics
2. Find methods to hook with Harmony
3. Explore the game's data structures

This project is automatically excluded from the build process for mod packaging.

## Packaging and Distribution
The `ZipPlugins` target in `Directory.Build.targets` automatically creates a BepInEx-compatible zip file containing your mod when building. The output is placed in the `Zips_$(ConfigurationName)` folder at the solution root, named according to your mod name, configuration, and version.

## Common Modding Tasks
- **Harmony Patching**: Use Harmony to patch game methods
- **Custom UI**: Create UI elements with Unity UI components
- **Asset Loading**: Load custom assets from embedded resources or asset bundles
- **Configuration**: Use BepInEx configuration system for user settings

## Debugging
For debugging, you can:
1. Use Unity Debug.Log/BepInEx Logger statements
2. Build in Debug configuration for more verbose information
3. Connect Visual Studio Code to the Unity debugger with additional setup

## Decompiling Game Code with dnSpy

Since the decompiled game code cannot be distributed in the git repository due to copyright concerns, you'll need to decompile it yourself:

1. **Download dnSpy**: 
   - Get the latest release from [dnSpy GitHub Releases](https://github.com/dnSpy/dnSpy/releases)
   - Download the appropriate version (typically the x64 version for most systems)

2. **Extract and Run dnSpy**:
   - Extract the downloaded archive to a location of your choice
   - Launch dnSpy.exe

3. **Load the Assembly-CSharp.dll**:
   - In dnSpy, go to File → Open
   - Navigate to your Pharaoh installation: `[GamePath]\Pharaoh_Data\Managed\`
   - Select Assembly-CSharp.dll and any other DLLs you're interested in

4. **Export Decompiled Code**:
   - Go to File → Export to Project... (as shown in the screenshot)
   - Choose "C#" as the language
   - Set the output directory to the `Assembly-CSharp` folder in your repository
   - Click OK and wait for the export to complete
   - The export will create a .csproj file and all the decompiled .cs files

5. **Clean Up if Needed**:
   - The exported code may contain some errors or warnings
   - These are typically not a problem for reference purposes
   - You can use the Assembly-CSharp.csproj from this repository as a reference

## Git Repository Setup

When setting up this repository as a git repository, here are some recommended configurations:

1. **Create a .gitignore file** with the following entries:
   ```
   # User-specific files
   GamePath.props
   
   # Build results
   [Bb]in/
   [Oo]bj/
   [Zz]ips_*/
   
   # Decompiled game code (copyright concerns)
   Assembly-CSharp/
   
   # VS Code files
   .vscode/*
   !.vscode/tasks.json
   !.vscode/launch.json
   !.vscode/extensions.json
   ```

2. **Initial Git Setup**:
   ```powershell
   git init
   git add .
   git commit -m "Initial commit"
   ```

3. **Adding a Remote Repository**:
   ```powershell
   git remote add origin <your-repository-url>
   git push -u origin main
   ```

4. **Documentation Branch**:
   Consider creating a separate branch for documentation about modding techniques:
   ```powershell
   git checkout -b documentation
   ```
   This branch can host the GitHub Pages content with modding guides and tutorials.

## GitHub Pages for Modding Documentation

You can use GitHub Pages to host documentation about modding techniques:

1. Create a `docs/` folder in your repository
2. Add markdown files with documentation about different modding aspects:
   - Harmony patching examples
   - Unity UI creation techniques
   - Game systems analysis
   - Common modding patterns

3. Enable GitHub Pages in your repository settings:
   - Go to Settings → Pages
   - Select the branch to publish from (e.g., main or documentation)
   - Choose the /docs folder as the source
   - Save the settings

The modding documentation will be available at `https://[your-username].github.io/[repo-name]/`
