# Pharaoh Modding Technical Reference

## Build System Configuration

### Directory.Build.props
This file contains centralized MSBuild properties that apply to all projects in the solution. Key configurations include:

```xml
<Project>
	<Import Project="GamePath.props" Condition="Exists('GamePath.props')" />
	
	<PropertyGroup>
		<AppendTargetFrameworkToOutputPath>false</AppendTargetFrameworkToOutputPath>
		<AppendRuntimeIdentifierToOutputPath>false</AppendRuntimeIdentifierToOutputPath>
        <OutputPath>$(SolutionDir)bin\$(Configuration)\$(ProjectName)\</OutputPath>
		<Configurations>Debug;Release</Configurations>
		<TargetFramework>net472</TargetFramework>
		<AllowUnsafeBlocks>true</AllowUnsafeBlocks>
		<RestoreAdditionalProjectSources>
			https://nuget.bepinex.dev/v3/index.json
		</RestoreAdditionalProjectSources>
		<LangVersion>8</LangVersion>
		<DebugType>embedded</DebugType>
	</PropertyGroup>
	
	<ItemDefinitionGroup>
		<PackageReference ExcludeAssets="runtime" />
	</ItemDefinitionGroup>

	<ItemGroup>
		<PackageReference Include="BepInEx.Core" Version="5.*" />
		<PackageReference Include="BepInEx.Analyzers" Version="1.*" PrivateAssets="all" />
		<PackageReference Include="BepInEx.PluginInfoProps" Version="*-*" />
		<PackageReference Include="PolySharp" Version="1.13.*" />
	</ItemGroup>

	<!-- Game DLL references -->
</Project>
```

### Directory.Build.targets
This file contains build tasks that run after the main build process:

```xml
<Project>
	<Target Name="ZipPlugins" AfterTargets="Build" Condition="$(AssemblyName.EndsWith('Tests')) == 'false' And $(AssemblyName) != 'Assembly-CSharp'">
		<PropertyGroup>
			<StagingDir>$(OutDir)\staging</StagingDir>
			<PluginsDir>$(StagingDir)\BepInEx\plugins</PluginsDir>
			<BuildDir>$([System.IO.Path]::Combine('$(PluginsDir)', '$(AssemblyName)'))</BuildDir>
			<BuildZipDir>$([System.IO.Path]::Combine('$(SolutionDir)', 'Zips_$(ConfigurationName)'))</BuildZipDir>
			<BuildZipPath>$([System.IO.Path]::Combine('$(BuildZipDir)', '$(AssemblyName)_$(ConfigurationName)_v$(Version).zip'))</BuildZipPath>
		</PropertyGroup>

		<!--Remove StagingDir if already exists -->
		<RemoveDir Directories="$(StagingDir)" />

		<!--Get List of output files before maing new staging dir-->
		<ItemGroup>
			<PluginsFiles Include="$(OutDir)\**\*.*" />
		</ItemGroup>

		<!--Ensure Output directories exist.-->
		<MakeDir Directories="$(StagingDir)" />
		<MakeDir Directories="$(PluginsDir)" />
		<MakeDir Directories="$(BuildDir)" />
		<MakeDir Directories="$(BuildZipDir)" />

		<!--Copy output files to staging dir-->
		<Copy SourceFiles="@(PluginsFiles)" DestinationFiles="@(PluginsFiles->'$(BuildDir)\%(RecursiveDir)%(Filename)%(Extension)')" />

		<!-- Main build zip file -->
		<ZipDirectory SourceDirectory="$(StagingDir)"
                      DestinationFile="$(BuildZipPath)"
                      Overwrite="true"/>

		<!-- Remove staging dir -->
		<RemoveDir Directories="$(StagingDir)" />
	</Target>
</Project>
```

### GamePath.props
This file contains the path to your Pharaoh installation:

```xml
<Project>
  <PropertyGroup>
    <!-- Update this path to your Pharaoh installation -->
    <GamePath>C:\Program Files (x86)\Steam\steamapps\common\Pharaoh A New Era</GamePath>
  </PropertyGroup>
</Project>
```

## Project Structure Details

### Minimal Mod Project (.csproj)
```xml
<Project Sdk="Microsoft.NET.Sdk">
  <PropertyGroup>
    <AssemblyName>PharaohMod</AssemblyName>
    <BepInExPluginName>Pharaoh Mod With Spaces</BepInExPluginName>
    <Description>A BepInEx mod for Pharaoh</Description>
    <Version>1.0.0</Version>
    <RootNamespace>PharaohMod</RootNamespace>
  </PropertyGroup>
</Project>
```

### BepInEx PluginInfoProps

The BepInEx.PluginInfoProps package is included in Directory.Build.props:

```xml
<PackageReference Include="BepInEx.PluginInfoProps" Version="*-*" />
```

This package auto-generates a `MyPluginInfo.cs` file during build with constants for:
- `PLUGIN_GUID`: Uses the AssemblyName (no spaces)
- `PLUGIN_NAME`: Uses the BepInExPluginName property (can contain spaces)
- `PLUGIN_VERSION`: Uses the Version property from the .csproj

You can reference these constants in your BepInPlugin attribute:

```csharp
[BepInPlugin(MyPluginInfo.PLUGIN_GUID, MyPluginInfo.PLUGIN_NAME, MyPluginInfo.PLUGIN_VERSION)]
```

The BepInExPluginName property allows you to specify a user-friendly display name with spaces while keeping your code DRY (Don't Repeat Yourself). This approach lets you maintain a single source of truth in your .csproj file for your plugin's metadata.

The auto-generated constants are:
1. **MyPluginInfo.PLUGIN_GUID**: A unique identifier for your plugin (based on AssemblyName)
2. **MyPluginInfo.PLUGIN_NAME**: The display name of your plugin (from BepInExPluginName)
3. **MyPluginInfo.PLUGIN_VERSION**: The version string (from Version property)

### BepInEx Plugin Template
```csharp
using BepInEx;
using BepInEx.Logging;
using UnityEngine;

namespace YourNamespace
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
            _logger.LogInfo($"Plugin {MyPluginInfo.PLUGIN_GUID} is loaded!");
            // Your plugin initialization code here
        }
    }
}
```

## Unity Version-Specific Information

### Unity 2019.4.38
- Runtime: .NET Framework 4.x compatible
- Target Framework: net472
- Key Unity modules referenced:
  - UnityEngine.CoreModule.dll
  - UnityEngine.UI.dll
  - UnityEngine.AnimationModule.dll
  - (and others as needed)

## Advanced Modding Techniques

### Harmony Patching Example
```csharp
using HarmonyLib;
using System.Reflection;

namespace YourMod
{
    [HarmonyPatch(typeof(TargetClass))]
    [HarmonyPatch("TargetMethod")]
    public static class PatchClass
    {
        [HarmonyPrefix]
        public static bool Prefix(ref string __result)
        {
            __result = "Modified Result";
            return false; // Skip original method
        }
    }

    public class Plugin : BaseUnityPlugin
    {
        private void Awake()
        {
            var harmony = new Harmony(MyPluginInfo.PLUGIN_GUID);
            harmony.PatchAll(Assembly.GetExecutingAssembly());
        }
    }
}
```

### Custom Unity UI Example
```csharp
using UnityEngine;
using UnityEngine.UI;

namespace YourMod
{
    public class CustomUI : MonoBehaviour
    {
        public static CustomUI Create()
        {
            GameObject go = new GameObject("CustomUI");
            CustomUI ui = go.AddComponent<CustomUI>();
            DontDestroyOnLoad(go);
            return ui;
        }

        private void Start()
        {
            // Create your custom UI components
            GameObject canvas = new GameObject("Canvas");
            canvas.transform.SetParent(transform);
            Canvas canvasComponent = canvas.AddComponent<Canvas>();
            canvasComponent.renderMode = RenderMode.ScreenSpaceOverlay;
            canvas.AddComponent<CanvasScaler>();
            canvas.AddComponent<GraphicRaycaster>();

            // Add UI elements
            GameObject panel = new GameObject("Panel");
            panel.transform.SetParent(canvas.transform);
            Image image = panel.AddComponent<Image>();
            image.color = new Color(0, 0, 0, 0.8f);
            RectTransform rect = panel.GetComponent<RectTransform>();
            rect.anchorMin = new Vector2(0, 0);
            rect.anchorMax = new Vector2(1, 1);
            rect.offsetMin = new Vector2(20, 20);
            rect.offsetMax = new Vector2(-20, -20);
        }
    }
}
```

## Debugging Techniques

### BepInEx Configuration
```csharp
using BepInEx.Configuration;

namespace YourMod
{
    public class Plugin : BaseUnityPlugin
    {
        // Config entries
        private ConfigEntry<bool> _enableFeature;
        private ConfigEntry<float> _featureStrength;

        private void Awake()
        {
            // Bind configuration entries
            _enableFeature = Config.Bind("General",
                                       "EnableFeature",
                                       true,
                                       "Enable or disable the main feature");

            _featureStrength = Config.Bind("General",
                                         "FeatureStrength",
                                         1.0f,
                                         "Strength of the feature (0.0 - 2.0)");

            // Use configuration values
            if (_enableFeature.Value)
            {
                DoSomethingWithStrength(_featureStrength.Value);
            }
        }

        private void DoSomethingWithStrength(float strength)
        {
            // Implementation
        }
    }
}
```

### Logging
```csharp
// Basic logging
_logger.LogInfo("Information message");
_logger.LogWarning("Warning message");
_logger.LogError("Error message");

// Detailed logging with object information
_logger.LogInfo($"Player position: {playerObject.transform.position}");
_logger.LogInfo($"Inventory items: {string.Join(", ", inventory.Items.Select(i => i.name))}");
```

## Asset Management

### Embedded Resources
```csharp
// In your .csproj file:
<ItemGroup>
  <EmbeddedResource Include="assets\*.*" />
</ItemGroup>

// In your code:
public static byte[] GetResource(string resourceName)
{
    Assembly assembly = Assembly.GetExecutingAssembly();
    string fullName = assembly.GetManifestResourceNames().FirstOrDefault(name => name.EndsWith(resourceName));
    
    if (string.IsNullOrEmpty(fullName))
        return null;
        
    using (Stream stream = assembly.GetManifestResourceStream(fullName))
    {
        if (stream == null)
            return null;
            
        byte[] data = new byte[stream.Length];
        stream.Read(data, 0, data.Length);
        return data;
    }
}

// Usage:
byte[] textureData = GetResource("myTexture.png");
Texture2D texture = new Texture2D(2, 2);
texture.LoadImage(textureData);
```

## Common Issues and Solutions

1. **Missing Assemblies**: If you get compiler errors about missing types or namespaces:
   - Make sure GamePath.props points to the correct location
   - Verify all required DLLs are referenced in Directory.Build.props
   - Check for version mismatches between BepInEx and game assemblies

2. **Mod Not Loading**: If your mod builds but doesn't load in the game:
   - Verify BepInEx is correctly installed in your game
   - Check BepInEx logs for error messages
   - Ensure the mod is in the correct plugins folder
   - Make sure the TargetFramework is set to net472

3. **Runtime Errors**: If your mod loads but causes errors:
   - Use try-catch blocks in your code to prevent crashes
   - Add detailed logging to identify the source of the problem
   - Check for null references when accessing game objects or components

## Decompiling and Working with Game Code

### Understanding the Decompiling Process

When working with the decompiled game code:

1. **Code Quality Issues**:
   - Decompiled code may contain compiler-generated names or unclear logic
   - Local variables might have generic names like `num1`, `flag2`, etc.
   - Some optimizations may make the code flow unclear

2. **Finding Important Classes**:
   - Start with main manager classes like `GameManager`, `BuildingManager`, etc.
   - Look for MonoBehaviour classes related to the features you want to mod
   - Explore static classes that might contain game constants or utility methods

3. **Dealing with Compiler Errors**:
   - Decompiled code might contain C# syntax errors
   - Focus on understanding the logic rather than fixing every error
   - You typically won't need to compile this code, just reference it

### Best Practices for Using Decompiled Code

1. **Reference Only**: Always treat the decompiled code as reference material, not code to be modified directly
2. **Use Harmony**: Instead of changing game code, use Harmony to patch methods at runtime
3. **Document Discoveries**: Keep notes on important classes, methods, and game systems you uncover

## Contributing to Modding Documentation

As you discover how to mod different aspects of the game, consider contributing to the modding documentation:

### Documentation Structure

For a well-organized modding guide, structure your findings into these categories:

1. **Game Systems**:
   - Building mechanics
   - Economy simulation
   - Walker behaviors
   - Military systems
   - etc.

2. **Modding Techniques**:
   - Adding new buildings
   - Modifying game rules
   - Creating custom UI
   - Adding new gameplay features

3. **Code Examples**:
   - Common patching patterns
   - Useful utility methods
   - Sample mods with explanations

### Creating Documentation in Markdown

When creating documentation files for the GitHub Pages site:

1. Use clear, descriptive headings and subheadings
2. Include code examples with syntax highlighting
3. Explain both what the code does and why it works
4. Include screenshots or diagrams where helpful

Example markdown structure:
```markdown
# Building System Modding

## Overview of the Building System
[Brief explanation of how buildings work in the game]

## Key Classes and Methods
- `Building.cs` - Base class for all buildings
- `BuildingManager.cs` - Handles building placement and management
- [...]

## Common Modding Scenarios

### Modifying Building Properties
[Code examples and explanation]

### Adding New Building Types
[Code examples and explanation]

### Changing Building Requirements
[Code examples and explanation]
```

### Setting Up GitHub Pages

1. Create a docs folder in your repository
2. Add an `index.md` file as the main page
3. Create subfolders for different categories of documentation
4. Configure GitHub Pages in your repository settings to use the docs folder
5. Consider adding a Jekyll theme for better presentation
