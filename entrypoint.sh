#!/usr/bin/env bash
set -e

# Always download Postal 2 server files
echo "Downloading Postal 2 server files..."

# Use a single SteamCMD command with force_install_dir before login
/home/steam/steamcmd/steamcmd.sh +force_install_dir /home/steam/postal2 +login $STEAM_USERNAME $STEAM_PASSWORD +app_update 223470 -beta "5025" +validate +quit
echo "Download complete!"

# Backup the default Postal2.ini if it exists and hasn't been backed up yet
if [ -f "/home/steam/postal2/System/Postal2.ini" ] && [ ! -f "/home/steam/postal2/System/Postal2.ini.bak" ]; then
    mv /home/steam/postal2/System/Postal2.ini /home/steam/postal2/System/Postal2.ini.bak
fi

# Create required directories
mkdir -p /home/steam/postal2/Maps
mkdir -p /home/steam/postal2/System

# Copy overrides from mounted directory if they exist
if [ -d "/tmp/postal2-overrides/Maps" ] && [ "$(ls -A /tmp/postal2-overrides/Maps 2>/dev/null)" ]; then
    echo "Copying custom maps..."
    cp -rf /tmp/postal2-overrides/Maps/* /home/steam/postal2/Maps/ 2>/dev/null || true
fi

if [ -d "/tmp/postal2-overrides/System" ] && [ "$(ls -A /tmp/postal2-overrides/System 2>/dev/null)" ]; then
    echo "Copying custom system files..."
    cp -rf /tmp/postal2-overrides/System/* /home/steam/postal2/System/ 2>/dev/null || true
fi

# Copy the custom Postal2.ini if it exists
if [ -f "/tmp/Postal2.ini" ]; then
    echo "Using custom Postal2.ini..."
    cp -f /tmp/Postal2.ini /home/steam/postal2/System/Postal2.ini
fi

echo "Starting Postal 2 server..."

# Configure Wine for headless operation
export DISPLAY=:0
export WINEDEBUG=fixme-all
export WINEPREFIX=/home/steam/.wine

# Initialize Wine in headless mode
winecfg -v win7 &>/dev/null || true

# Change to the Postal 2 directory
cd /home/steam/postal2
echo "Running Postal 2 server directly..."
#exec wine "System/ucc.exe server NicksCoopMapLoader.fuk?Game=NicksCoop.CoopGameInfo ini=Postal2CoOp.ini log=Server.log"

# leave interactive shell running
exec bash