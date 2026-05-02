@echo off
setlocal

:: Suppress the error if the directory already exists
mkdir C:\Developers\F2FZephyr\repos 2>nul
cd /d C:\Developers\F2FZephyr\repos
if %ERRORLEVEL% NEQ 0 goto :Fail_Directory

echo ** Checking and Installing Packages...
echo **********************
echo **
echo ** PLEASE CHECK FOR ADMIN ELEVATION PROMPT
echo ** DURING PODMAN INSTALL (If required)
echo **
echo **********************

:: Check for Podman
where podman >nul 2>nul
if %ERRORLEVEL% equ 0 (
    echo ** Podman is already installed. Skipping...
) else (
    echo ** Installing Podman...
    winget install -e --id RedHat.Podman --silent --accept-package-agreements --accept-source-agreements
    if %ERRORLEVEL% NEQ 0 goto :Fail_Winget_Podman
)

:: Check for uv
where uv >nul 2>nul
if %ERRORLEVEL% equ 0 (
    echo ** uv is already installed. Skipping...
) else (
    echo ** Installing uv...
    winget install -e --id astral-sh.uv --silent --accept-package-agreements --accept-source-agreements
    if %ERRORLEVEL% NEQ 0 goto :Fail_Winget_uv
)

:: Check for Git
where git >nul 2>nul
if %ERRORLEVEL% equ 0 (
    echo ** Git is already installed. Skipping...
) else (
    echo ** Installing Git...
    winget install -e --id Git.Git --silent --accept-package-agreements --accept-source-agreements
    if %ERRORLEVEL% NEQ 0 goto :Fail_Winget_Git
)

:: Safely refresh the PATH environment variable inside a Batch script
echo ** Refreshing Environment Variables...
for /f "delims=" %%i in ('powershell -NoProfile -Command "[System.Environment]::GetEnvironmentVariable('Path','Machine') + ';' + [System.Environment]::GetEnvironmentVariable('Path','User')"') do set "PATH=%%i"

echo ** Initializing Podman Machine (8 Cores, 16GB RAM)...
podman machine init --cpus 8 --memory 16384
if %ERRORLEVEL% NEQ 0 goto :Fail_Podman_Init
podman machine start
if %ERRORLEVEL% NEQ 0 goto :Fail_Podman_Start

echo ** Pulling Zephyr Build Environment...
echo ****** This may take a while with minimal feedback.  Hang tight!...
echo **
podman pull ghcr.io/zephyrproject-rtos/zephyr-build:v0.29.2
if %ERRORLEVEL% NEQ 0 goto :Fail_Podman_Pull

echo ** Pulling git Repositories... 
echo ****** This may take a while...
echo **

git clone --bare https://github.com/zephyrproject-rtos/zephyr.git
if %ERRORLEVEL% NEQ 0 goto :Fail_Git_Zephyr
if not exist "zephyr.git\" goto :Fail_Git_Zephyr

git clone --bare https://github.com/zephyrproject-rtos/cmsis.git
if %ERRORLEVEL% NEQ 0 goto :Fail_Git_CMSIS
if not exist "cmsis.git\" goto :Fail_Git_CMSIS

git clone --bare https://github.com/zephyrproject-rtos/CMSIS_6.git cmsis_6.git
if %ERRORLEVEL% NEQ 0 goto :Fail_Git_CMSIS6
if not exist "cmsis_6.git\" goto :Fail_Git_CMSIS6

git clone --bare https://github.com/zephyrproject-rtos/hal_microchip.git
if %ERRORLEVEL% NEQ 0 goto :Fail_Git_HAL
if not exist "hal_microchip.git\" goto :Fail_Git_HAL

echo ** Installing Python 3.12...
uv python install 3.12
if %ERRORLEVEL% NEQ 0 goto :Fail_UV_Python

echo ** Creating Python Virtual Environment...
cd ..
uv venv --python 3.12
if %ERRORLEVEL% NEQ 0 goto :Fail_UV_Venv

call .venv\Scripts\activate.bat
if %ERRORLEVEL% NEQ 0 goto :Fail_Venv_Activate

uv pip install west pyocd==0.43.0
if %ERRORLEVEL% NEQ 0 goto :Fail_UV_Pip

pyocd pack install pic32cm
if %ERRORLEVEL% NEQ 0 goto :Fail_PyOCD

echo *******************
echo **
echo ** To Uninstall, please complete the following:
echo ** podman machine reset --force
echo ** winget uninstall astral-sh.uv RedHat.Podman Git.Git
echo ** rmdir /S /Q C:\Developers\F2FZephyr\
echo **
echo *******************
echo ** Setup Complete! Everything installed successfully.
echo *******************
pause
endlocal
exit /b 0

:: ==========================================
:: ERROR HANDLING BLOCKS
:: ==========================================

:Fail_Directory
echo. & echo ERROR: Failed to create or access C:\Developers\F2FZephyr\repos. Check folder permissions. & goto :EndError
:Fail_Winget_Podman
echo. & echo ERROR: winget failed to install Podman. & goto :EndError
:Fail_Winget_uv
echo. & echo ERROR: winget failed to install uv. & goto :EndError
:Fail_Winget_Git
echo. & echo ERROR: winget failed to install Git. & goto :EndError
:Fail_Podman_Init
echo. & echo ERROR: Failed to initialize the Podman machine. It may already exist, or virtualization is disabled in the BIOS/Hyper-V. & goto :EndError
:Fail_Podman_Start
echo. & echo ERROR: Failed to start the Podman machine. & goto :EndError
:Fail_Podman_Pull
echo. & echo ERROR: Podman failed to pull the Zephyr build environment image. Check your network connection. & goto :EndError
:Fail_Git_Zephyr
echo. & echo ERROR: Git failed to clone the Zephyr repository. Check your network connection. & goto :EndError
:Fail_Git_CMSIS
echo. & echo ERROR: Git failed to clone the CMSIS repository. & goto :EndError
:Fail_Git_CMSIS6
echo. & echo ERROR: Git failed to clone the CMSIS_6 repository. & goto :EndError
:Fail_Git_HAL
echo. & echo ERROR: Git failed to clone the Microchip HAL repository. & goto :EndError
:Fail_UV_Python
echo. & echo ERROR: uv failed to install Python 3.12. & goto :EndError
:Fail_UV_Venv
echo. & echo ERROR: uv failed to create the Python virtual environment. & goto :EndError
:Fail_Venv_Activate
echo. & echo ERROR: Failed to activate the Python virtual environment. & goto :EndError
:Fail_UV_Pip
echo. & echo ERROR: uv failed to install west and pyocd. & goto :EndError
:Fail_PyOCD
echo. & echo ERROR: pyocd failed to install the pic32cm pack. & goto :EndError

:EndError
echo.
echo **********************************************************
echo ** SETUP FAILED. Please review the error message above. **
echo ** Attempt to re-run the script, then contact Dan Tang  **
echo ** if you continue to have issues.                      **    
echo **********************************************************
pause
endlocal
exit /b 1