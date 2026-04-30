@echo off

mkdir C:\Developers\F2FZephyr\repos
cd C:\Developers\F2FZephyr\repos

echo ** Installing Podman...
echo **********************
echo **
echo ** PLEASE CHECK FOR ADMIN ELEVATION PROMPT**
echo **     DURING PODMAN INSTALL
echo **
echo **********************

winget install -e --id RedHat.Podman  --silent --accept-package-agreements --accept-source-agreements

echo ** Initializing Podman Machine (4 Cores, 8GB RAM)...
"C:\Program Files\RedHat\Podman\podman" machine init --cpus 8 --memory 16384
"C:\Program Files\RedHat\Podman\podman" machine start

echo ** Pulling Zephyr Build Environment...
echo ****** This may take a while with minimal feedback.  Hang tight!...
echo **
"C:\Program Files\RedHat\Podman\podman" pull ghcr.io/zephyrproject-rtos/zephyr-build:v0.29.2

echo ** Pulling git Repositories... 
echo ****** This may take a while...
echo **
winget install git.git
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
git clone --bare https://github.com/zephyrproject-rtos/zephyr.git
git clone --bare https://github.com/zephyrproject-rtos/cmsis.git
git clone --bare https://github.com/zephyrproject-rtos/CMSIS_6.git cmsis_6.git
git clone --bare https://github.com/zephyrproject-rtos/hal_microchip.git

echo ** Installing Python 3.12...
winget install -e --id astral-sh.uv
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
uv python install 3.12

echo ** Creating Python Virtual Environment...
cd ..
uv venv --python 3.12
call .venv\Scripts\activate.bat
uv pip install west pyocd==0.43.0
pyocd pack install pic32cm

echo *******************
echo **
echo ** To Uninstall, please complete the following:
echo **    podman machine reset --force
echo **    winget uninstall uv podman
echo **    rm c:\developers\F2FZephyr\    (or otherwise delete this folder)
echo **
echo *******************
echo ** Setup Complete!
echo *******************