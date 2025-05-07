@echo off
REM filepath: c:\Repos\MrPurple6411\Pharaoh\PublicizeDependencies.bat

setlocal EnableDelayedExpansion

SET GAME_DEFAULT_PATH=C:\Program Files (x86)\Steam\steamapps\common\Pharaoh A New Era
SET GAME_MANAGED_PATH=%GAME_DEFAULT_PATH%\Pharaoh_Data\Managed
SET DEPENDENCIES_DIR=.\Dependencies
SET CHECKSUM_FILE=%DEPENDENCIES_DIR%\.checksum

echo Checking for game files...

REM Check if game files exist in default location
IF NOT EXIST "%GAME_MANAGED_PATH%" (
    echo Game not found at default location: %GAME_MANAGED_PATH%
    echo Looking for game installation in Steam library folders...
    
    REM Try to find Steam's libraryfolders.vdf to locate alternate install locations
    SET FOUND=0
    SET STEAM_PATH=
    
    REM Common Steam installation paths
    FOR %%p IN (
        "C:\Program Files (x86)\Steam"
        "C:\Program Files\Steam"
        "D:\Steam"
        "E:\Steam"
    ) DO (
        IF EXIST "%%p\steamapps\libraryfolders.vdf" (
            SET STEAM_PATH=%%p
            echo Found Steam at: %%p
        )
    )
    
    REM Check if we found Steam
    IF "%STEAM_PATH%"=="" (
        echo Could not find Steam installation.
        echo Please manually specify the game path in GamePath.props
        echo Example: ^<GamePath^>D:\SteamLibrary\steamapps\common\Pharaoh A New Era^</GamePath^>
        exit /b 1
    ) ELSE (
        REM Try to find Pharaoh in the Steam library folders
        FOR /f "tokens=*" %%a IN ('dir /b /s /a:d "%STEAM_PATH%\steamapps\common\Pharaoh A New Era" 2^>nul') DO (
            IF EXIST "%%a\Pharaoh_Data\Managed" (
                echo Found game at: %%a
                SET GAME_MANAGED_PATH=%%a\Pharaoh_Data\Managed
                SET FOUND=1
                goto :GAME_FOUND
            )
        )
    )
    
    :GAME_FOUND
    IF %FOUND%==0 (
        echo.
        echo ERROR: Pharaoh A New Era not found in any Steam library!
        echo Please make sure the game is installed or manually specify the game path in GamePath.props
        exit /b 1
    )
)

echo Game files found at: %GAME_MANAGED_PATH%

REM Generate checksum of key game files
echo Calculating checksums of game files...
SET CURRENT_CHECKSUM=
FOR %%f IN ("%GAME_MANAGED_PATH%\Assembly-CSharp.dll" "%GAME_MANAGED_PATH%\UnityEngine.dll" "%GAME_MANAGED_PATH%\UnityEngine.CoreModule.dll") DO (
    FOR /f "tokens=*" %%h IN ('certutil -hashfile "%%f" MD5 ^| findstr /v "CertUtil: -hashfile" ^| findstr /v ":"') DO (
        SET CURRENT_CHECKSUM=!CURRENT_CHECKSUM!%%h
    )
)

REM Check if we need to update dependencies
SET NEEDS_UPDATE=1

IF EXIST "%CHECKSUM_FILE%" (
    echo Checking if game files have changed...
    SET /p STORED_CHECKSUM=<"%CHECKSUM_FILE%"
    
    IF "!CURRENT_CHECKSUM!"=="!STORED_CHECKSUM!" (
        echo Game files have not changed since last run, using cached dependencies.
        SET NEEDS_UPDATE=0
    ) ELSE (
        echo Game files have changed, regenerating dependencies...
    )
) ELSE (
    echo No previous checksum found, generating dependencies...
)

IF !NEEDS_UPDATE!==1 (
    REM Delete existing files if they exist
    IF EXIST "%DEPENDENCIES_DIR%" (
        echo Deleting existing dependency files...
        rmdir /S /Q "%DEPENDENCIES_DIR%"
    )
    
    echo Creating Dependencies directory...
    mkdir "%DEPENDENCIES_DIR%"

echo Running NStrip to publicize dependencies...
nstrip -p -cg -cg-exclude-events -t ValueRet --remove-readonly --unity-non-serialized "%GAME_MANAGED_PATH%" "%DEPENDENCIES_DIR%"

IF %ERRORLEVEL% NEQ 0 (
    echo.
    echo ERROR: NStrip failed with error code %ERRORLEVEL%
    exit /b %ERRORLEVEL%
)

REM Save the checksum for future runs
echo !CURRENT_CHECKSUM!> "%CHECKSUM_FILE%"
echo Saved checksum file for future reference.
) ELSE (
    echo Skipping NStrip, using existing dependencies.
)

echo.
echo Dependencies ready! Files are in the %DEPENDENCIES_DIR% folder.

exit /b 0