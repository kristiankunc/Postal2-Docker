#!/usr/bin/env bash
set -e

# Ensure Steam directories have correct permissions
echo "Checking and fixing permissions..."
mkdir -p /home/steam/Steam/steamapps/common
chmod -R 755 /home/steam/Steam
chmod -R 755 /home/steam/steamcmd

# Always download Postal 2 server files
echo "Downloading Postal 2 server files..."
/home/steam/steamcmd/steamcmd.sh +login $STEAM_USERNAME $STEAM_PASSWORD +app_update 223470 -beta "5025" +validate +quit

echo "Download complete!"

# Set default SteamCMD installation path for Postal 2
POSTAL2_DIR="/home/steam/Steam/steamapps/common/Postal2"

# Backup the default Postal2.ini if it exists and hasn't been backed up yet
if [ -f "${POSTAL2_DIR}/System/Postal2.ini" ] && [ ! -f "${POSTAL2_DIR}/System/Postal2.ini.bak" ]; then
    mv ${POSTAL2_DIR}/System/Postal2.ini ${POSTAL2_DIR}/System/Postal2.ini.bak
fi

# Create required directories
mkdir -p ${POSTAL2_DIR}/Maps
mkdir -p ${POSTAL2_DIR}/System

# Copy overrides from mounted directory if they exist
if [ -d "/tmp/postal2-overrides/Maps" ] && [ "$(ls -A /tmp/postal2-overrides/Maps 2>/dev/null)" ]; then
    echo "Copying custom maps..."
    cp -rf /tmp/postal2-overrides/Maps/* ${POSTAL2_DIR}/Maps/ 2>/dev/null || true
fi

if [ -d "/tmp/postal2-overrides/System" ] && [ "$(ls -A /tmp/postal2-overrides/System 2>/dev/null)" ]; then
    echo "Copying custom system files..."
    cp -rf /tmp/postal2-overrides/System/* ${POSTAL2_DIR}/System/ 2>/dev/null || true
fi

# Copy the custom Postal2.ini if it exists
if [ -f "/tmp/Postal2.ini" ]; then
    echo "Using custom Postal2.ini..."
    cp -f /tmp/Postal2.ini ${POSTAL2_DIR}/System/Postal2.ini
fi

echo "Starting Postal 2 server..."

# Configure Wine for headless operation
export DISPLAY=:0
export WINEDEBUG=fixme-all
export WINEPREFIX=/home/steam/.wine

# Initialize Wine in headless mode
winecfg -v win7 &>/dev/null || true

# Change to the Postal 2 directory
cd ${POSTAL2_DIR}
echo "Running Postal 2 server directly..."
#exec wine "System/ucc.exe server NicksCoopMapLoader.fuk?Game=NicksCoop.CoopGameInfo ini=Postal2CoOp.ini log=Server.log"

# leave interactive shell running
exec bash