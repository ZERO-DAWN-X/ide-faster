@echo off
setlocal enabledelayedexpansion

:: Initialize selection flags
set "sel_cursor=0"
set "sel_vscode=0"
set "sel_vscode_insiders=0"
set "sel_claude=0"
set "sel_windsurf=0"
set "sel_discord=0"
set "sel_github=0"
set "sel_figma=0"
set "sel_obs=0"

:MENU
cls
echo ================================================
echo    IDE Cache Mover - Multiple Selection
echo ================================================
echo.
echo Select IDEs to move (toggle with number, then press M to move):
echo.

if "%sel_cursor%"=="1" (
    echo  [X] 1. Cursor
) else (
    echo  [ ] 1. Cursor
)

if "%sel_vscode%"=="1" (
    echo  [X] 2. VS Code
) else (
    echo  [ ] 2. VS Code
)

if "%sel_vscode_insiders%"=="1" (
    echo  [X] 3. VS Code Insiders
) else (
    echo  [ ] 3. VS Code Insiders
)

if "%sel_claude%"=="1" (
    echo  [X] 4. Claude
) else (
    echo  [ ] 4. Claude
)

if "%sel_windsurf%"=="1" (
    echo  [X] 5. Windsurf
) else (
    echo  [ ] 5. Windsurf
)

if "%sel_discord%"=="1" (
    echo  [X] 6. Discord
) else (
    echo  [ ] 6. Discord
)

if "%sel_github%"=="1" (
    echo  [X] 7. GitHub Desktop
) else (
    echo  [ ] 7. GitHub Desktop
)

if "%sel_figma%"=="1" (
    echo  [X] 8. Figma
) else (
    echo  [ ] 8. Figma
)

if "%sel_obs%"=="1" (
    echo  [X] 9. OBS Studio
) else (
    echo  [ ] 9. OBS Studio
)

echo.
echo ================================================
echo.
echo  [A] Select All
echo  [N] Deselect All
echo  [M] Move Selected IDEs
echo  [0] Exit
echo.
echo ================================================
echo.

set /p choice="Enter your choice (1-9, A, N, M, or 0): "

if /i "%choice%"=="0" goto END
if /i "%choice%"=="A" goto SELECT_ALL
if /i "%choice%"=="N" goto DESELECT_ALL
if /i "%choice%"=="M" goto CONFIRM_MOVE

if "%choice%"=="1" (
    if "%sel_cursor%"=="1" (
        set "sel_cursor=0"
    ) else (
        set "sel_cursor=1"
    )
    goto MENU
)

if "%choice%"=="2" (
    if "%sel_vscode%"=="1" (
        set "sel_vscode=0"
    ) else (
        set "sel_vscode=1"
    )
    goto MENU
)

if "%choice%"=="3" (
    if "%sel_vscode_insiders%"=="1" (
        set "sel_vscode_insiders=0"
    ) else (
        set "sel_vscode_insiders=1"
    )
    goto MENU
)

if "%choice%"=="4" (
    if "%sel_claude%"=="1" (
        set "sel_claude=0"
    ) else (
        set "sel_claude=1"
    )
    goto MENU
)

if "%choice%"=="5" (
    if "%sel_windsurf%"=="1" (
        set "sel_windsurf=0"
    ) else (
        set "sel_windsurf=1"
    )
    goto MENU
)

if "%choice%"=="6" (
    if "%sel_discord%"=="1" (
        set "sel_discord=0"
    ) else (
        set "sel_discord=1"
    )
    goto MENU
)

if "%choice%"=="7" (
    if "%sel_github%"=="1" (
        set "sel_github=0"
    ) else (
        set "sel_github=1"
    )
    goto MENU
)

if "%choice%"=="8" (
    if "%sel_figma%"=="1" (
        set "sel_figma=0"
    ) else (
        set "sel_figma=1"
    )
    goto MENU
)

if "%choice%"=="9" (
    if "%sel_obs%"=="1" (
        set "sel_obs=0"
    ) else (
        set "sel_obs=1"
    )
    goto MENU
)

echo Invalid choice! Press any key to try again...
pause >nul
goto MENU

:SELECT_ALL
set "sel_cursor=1"
set "sel_vscode=1"
set "sel_vscode_insiders=1"
set "sel_claude=1"
set "sel_windsurf=1"
set "sel_discord=1"
set "sel_github=1"
set "sel_figma=1"
set "sel_obs=1"
goto MENU

:DESELECT_ALL
set "sel_cursor=0"
set "sel_vscode=0"
set "sel_vscode_insiders=0"
set "sel_claude=0"
set "sel_windsurf=0"
set "sel_discord=0"
set "sel_github=0"
set "sel_figma=0"
set "sel_obs=0"
goto MENU

:CONFIRM_MOVE
cls
echo ================================================
echo    Confirmation
echo ================================================
echo.
echo You are about to move the following IDEs:
echo.

set "count=0"
if "%sel_cursor%"=="1" (
    echo  - Cursor
    set /a count+=1
)
if "%sel_vscode%"=="1" (
    echo  - VS Code
    set /a count+=1
)
if "%sel_vscode_insiders%"=="1" (
    echo  - VS Code Insiders
    set /a count+=1
)
if "%sel_claude%"=="1" (
    echo  - Claude
    set /a count+=1
)
if "%sel_windsurf%"=="1" (
    echo  - Windsurf
    set /a count+=1
)
if "%sel_discord%"=="1" (
    echo  - Discord
    set /a count+=1
)
if "%sel_github%"=="1" (
    echo  - GitHub Desktop
    set /a count+=1
)
if "%sel_figma%"=="1" (
    echo  - Figma
    set /a count+=1
)
if "%sel_obs%"=="1" (
    echo  - OBS Studio
    set /a count+=1
)

if "%count%"=="0" (
    echo.
    echo No IDEs selected!
    echo Press any key to return to menu...
    pause >nul
    goto MENU
)

echo.
echo Total: %count% IDE(s) selected
echo.
echo WARNING: Please close ALL selected applications first!
echo.
set /p confirm="Continue? (Y/N): "

if /i not "%confirm%"=="Y" goto MENU

goto MOVE_SELECTED

:MOVE_SELECTED
cls
echo ================================================
echo Moving Selected IDEs
echo ================================================
echo.

mkdir "D:\AppData\Roaming" 2>nul

if "%sel_cursor%"=="1" call :PROCESS_CURSOR
if "%sel_vscode%"=="1" call :PROCESS_VSCODE
if "%sel_vscode_insiders%"=="1" call :PROCESS_VSCODE_INSIDERS
if "%sel_claude%"=="1" call :PROCESS_CLAUDE
if "%sel_windsurf%"=="1" call :PROCESS_WINDSURF
if "%sel_discord%"=="1" call :PROCESS_DISCORD
if "%sel_github%"=="1" call :PROCESS_GITHUB
if "%sel_figma%"=="1" call :PROCESS_FIGMA
if "%sel_obs%"=="1" call :PROCESS_OBS

echo.
echo ================================================
echo Selected IDEs moved successfully!
echo ================================================
echo.
echo Press any key to return to menu...
pause >nul

:: Reset selections after successful move
set "sel_cursor=0"
set "sel_vscode=0"
set "sel_vscode_insiders=0"
set "sel_claude=0"
set "sel_windsurf=0"
set "sel_discord=0"
set "sel_github=0"
set "sel_figma=0"
set "sel_obs=0"

goto MENU

:: ============================================
:: PROCESSING FUNCTIONS
:: ============================================
:PROCESS_CURSOR
echo [Cursor]
if exist "%AppData%\Cursor" (
    echo   Checking if already a junction...
    dir "%AppData%\Cursor" | find "<JUNCTION>" >nul
    if !errorlevel! equ 0 (
        echo   Already moved! Skipping...
    ) else (
        echo   Moving folder...
        robocopy "%AppData%\Cursor" "D:\AppData\Roaming\Cursor" /E /MOVE /NFL /NDL /NJH /NJS
        rmdir "%AppData%\Cursor" /S /Q 2>nul
        mklink /J "%AppData%\Cursor" "D:\AppData\Roaming\Cursor" >nul
        echo   Done!
    )
) else (
    echo   Folder not found, skipping...
)
echo.
goto :EOF

:PROCESS_VSCODE
echo [VS Code]
if exist "%AppData%\Code" (
    echo   Checking if already a junction...
    dir "%AppData%\Code" | find "<JUNCTION>" >nul
    if !errorlevel! equ 0 (
        echo   Already moved! Skipping...
    ) else (
        echo   Moving folder...
        robocopy "%AppData%\Code" "D:\AppData\Roaming\Code" /E /MOVE /NFL /NDL /NJH /NJS
        rmdir "%AppData%\Code" /S /Q 2>nul
        mklink /J "%AppData%\Code" "D:\AppData\Roaming\Code" >nul
        echo   Done!
    )
) else (
    echo   Folder not found, skipping...
)
echo.
goto :EOF

:PROCESS_VSCODE_INSIDERS
echo [VS Code Insiders]
if exist "%AppData%\Code - Insiders" (
    echo   Checking if already a junction...
    dir "%AppData%\Code - Insiders" | find "<JUNCTION>" >nul
    if !errorlevel! equ 0 (
        echo   Already moved! Skipping...
    ) else (
        echo   Moving folder...
        robocopy "%AppData%\Code - Insiders" "D:\AppData\Roaming\Code-Insiders" /E /MOVE /NFL /NDL /NJH /NJS
        rmdir "%AppData%\Code - Insiders" /S /Q 2>nul
        mklink /J "%AppData%\Code - Insiders" "D:\AppData\Roaming\Code-Insiders" >nul
        echo   Done!
    )
) else (
    echo   Folder not found, skipping...
)
echo.
goto :EOF

:PROCESS_CLAUDE
echo [Claude]
if exist "%AppData%\Claude" (
    echo   Checking if already a junction...
    dir "%AppData%\Claude" | find "<JUNCTION>" >nul
    if !errorlevel! equ 0 (
        echo   Already moved! Skipping...
    ) else (
        echo   Moving folder...
        robocopy "%AppData%\Claude" "D:\AppData\Roaming\Claude" /E /MOVE /NFL /NDL /NJH /NJS
        rmdir "%AppData%\Claude" /S /Q 2>nul
        mklink /J "%AppData%\Claude" "D:\AppData\Roaming\Claude" >nul
        echo   Done!
    )
) else (
    echo   Folder not found, skipping...
)
echo.
goto :EOF

:PROCESS_WINDSURF
echo [Windsurf]
if exist "%AppData%\Windsurf" (
    echo   Checking if already a junction...
    dir "%AppData%\Windsurf" | find "<JUNCTION>" >nul
    if !errorlevel! equ 0 (
        echo   Already moved! Skipping...
    ) else (
        echo   Moving folder...
        robocopy "%AppData%\Windsurf" "D:\AppData\Roaming\Windsurf" /E /MOVE /NFL /NDL /NJH /NJS
        rmdir "%AppData%\Windsurf" /S /Q 2>nul
        mklink /J "%AppData%\Windsurf" "D:\AppData\Roaming\Windsurf" >nul
        echo   Done!
    )
) else (
    echo   Folder not found, skipping...
)
echo.
goto :EOF

:PROCESS_DISCORD
echo [Discord]
if exist "%AppData%\discord" (
    echo   Checking if already a junction...
    dir "%AppData%\discord" | find "<JUNCTION>" >nul
    if !errorlevel! equ 0 (
        echo   Already moved! Skipping...
    ) else (
        echo   Moving folder...
        robocopy "%AppData%\discord" "D:\AppData\Roaming\discord" /E /MOVE /NFL /NDL /NJH /NJS
        rmdir "%AppData%\discord" /S /Q 2>nul
        mklink /J "%AppData%\discord" "D:\AppData\Roaming\discord" >nul
        echo   Done!
    )
) else (
    echo   Folder not found, skipping...
)
echo.
goto :EOF

:PROCESS_GITHUB
echo [GitHub Desktop]
if exist "%AppData%\GitHub Desktop" (
    echo   Checking if already a junction...
    dir "%AppData%\GitHub Desktop" | find "<JUNCTION>" >nul
    if !errorlevel! equ 0 (
        echo   Already moved! Skipping...
    ) else (
        echo   Moving folder...
        robocopy "%AppData%\GitHub Desktop" "D:\AppData\Roaming\GitHub-Desktop" /E /MOVE /NFL /NDL /NJH /NJS
        rmdir "%AppData%\GitHub Desktop" /S /Q 2>nul
        mklink /J "%AppData%\GitHub Desktop" "D:\AppData\Roaming\GitHub-Desktop" >nul
        echo   Done!
    )
) else (
    echo   Folder not found, skipping...
)
echo.
goto :EOF

:PROCESS_FIGMA
echo [Figma]
if exist "%AppData%\Figma" (
    echo   Checking if already a junction...
    dir "%AppData%\Figma" | find "<JUNCTION>" >nul
    if !errorlevel! equ 0 (
        echo   Already moved! Skipping...
    ) else (
        echo   Moving folder...
        robocopy "%AppData%\Figma" "D:\AppData\Roaming\Figma" /E /MOVE /NFL /NDL /NJH /NJS
        rmdir "%AppData%\Figma" /S /Q 2>nul
        mklink /J "%AppData%\Figma" "D:\AppData\Roaming\Figma" >nul
        echo   Done!
    )
) else (
    echo   Folder not found, skipping...
)
echo.
goto :EOF

:PROCESS_OBS
echo [OBS Studio]
if exist "%AppData%\obs-studio" (
    echo   Checking if already a junction...
    dir "%AppData%\obs-studio" | find "<JUNCTION>" >nul
    if !errorlevel! equ 0 (
        echo   Already moved! Skipping...
    ) else (
        echo   Moving folder...
        robocopy "%AppData%\obs-studio" "D:\AppData\Roaming\obs-studio" /E /MOVE /NFL /NDL /NJH /NJS
        rmdir "%AppData%\obs-studio" /S /Q 2>nul
        mklink /J "%AppData%\obs-studio" "D:\AppData\Roaming\obs-studio" >nul
        echo   Done!
    )
) else (
    echo   Folder not found, skipping...
)
echo.
goto :EOF

:END
echo.
echo Exiting...
exit /b