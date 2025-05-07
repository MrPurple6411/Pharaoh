# Pharaoh Modding Workspace

This repository contains a setup for modding Pharaoh using BepInEx.

## Setup Instructions

1. Clone this repository
2. Open the solution in Visual Studio Code or Visual Studio
3. Create a `GamePath.props` file at the solution root with your Pharaoh installation path:

```xml
<Project>
  <PropertyGroup>
    <GamePath>C:\Path\To\Your\Pharaoh\Installation</GamePath>
  </PropertyGroup>
</Project>
```

4. Build the solution
5. Your mods will be created in the `Zips_Release` or `Zips_Debug` directory

## Project Structure

- **Assembly-CSharp**: Decompiled game code, for reference only
- **PharaohMod**: Template BepInEx plugin project

## Creating New Mods

To create a new mod:
1. Copy the PharaohMod directory to a new directory with your mod name
2. Update the project references as needed
3. Add your mod to the solution file
4. Update the AssemblyName, Description, and other properties in the .csproj file

## Dependencies

This project uses BepInEx 5.x. Make sure to install it in your game directory.
