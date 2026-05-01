@echo off
setlocal

:: Suppress the error if the directory already exists
mkdir C:\Developers\F2FZephyr\repos 2>nul
cd /d C:\Developers\F2FZephyr\repos

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
)

:: Check for uv
where uv >nul 2>nul
if %ERRORLEVEL% equ 0 (
    echo ** uv is already installed. Skipping...
) else (
    echo ** Installing uv...
    winget install -e --id astral-sh.uv --silent --accept-package-agreements --accept-source-agreements
)

:: Check for Git
where git >nul 2>nul
if %ERRORLEVEL% equ 0 (
    echo ** Git is already installed. Skipping...
) else (
    echo ** Installing Git...
    winget install -e --id Git.Git --silent --accept-package-agreements --accept-source-agreements
)

:: Safely refresh the PATH environment variable inside a Batch script
echo ** Refreshing Environment Variables...
for /f "delims=" %%i in ('powershell -NoProfile -Command "[System.Environment]::GetEnvironmentVariable('Path','Machine') + ';' + [System.Environment]::GetEnvironmentVariable('Path','User')"') do set "PATH=%%i"

echo ** Initializing Podman Machine (8 Cores, 16GB RAM)...
podman machine init --cpus 8 --memory 16384
podman machine start

echo ** Pulling Zephyr Build Environment...
echo ****** Copying Blobs may take a while with minimal feedback.  Hang tight!...
echo **
podman pull ghcr.io/zephyrproject-rtos/zephyr-build:v0.29.2

echo ** Pulling git Repositories... 
echo ****** This may take a while...
echo **

git clone --bare https://github.com/zephyrproject-rtos/zephyr.git
git clone --bare https://github.com/zephyrproject-rtos/cmsis.git
git clone --bare https://github.com/zephyrproject-rtos/CMSIS_6.git cmsis_6.git
git clone --bare https://github.com/zephyrproject-rtos/hal_microchip.git

echo ** Installing Python 3.12...
uv python install 3.12

echo ** Creating Python Virtual Environment...
cd ..
uv venv --python 3.12
call .venv\Scripts\activate.bat
Uv pip install jsonschema
uv pip install west pyocd==0.43.0
pyocd pack install pic32cm

echo *******************
echo **
echo ** To Uninstall, please complete the following:
echo ** podman machine reset --force
echo ** winget uninstall astral-sh.uv RedHat.Podman Git.Git
echo ** rmdir /S /Q C:\Developers\F2FZephyr\
echo **
echo *******************
echo ** Setup Complete!
echo *******************
endlocal