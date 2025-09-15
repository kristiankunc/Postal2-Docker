#!/usr/bin/env bash
set -e
echo "Download complete!"

# Set default SteamCMD installation path for Postal 2
POSTAL2_DIR="/home/dude/game"

# Backup the default Postal2.ini if it exists and hasn't been backed up yet
if [ -f "${POSTAL2_DIR}/System/Postal2.ini" ] && [ ! -f "${POSTAL2_DIR}/System/Postal2.ini.bak" ]; then
    mv ${POSTAL2_DIR}/System/Postal2.ini ${POSTAL2_DIR}/System/Postal2.ini.bak
fi

echo "Copying all overrides from /tmp/postal2-overrides..."
cp -rf /tmp/postal2-overrides/* ${POSTAL2_DIR}/ 2>/dev/null || true

# Copy the custom Postal2.ini if it exists
if [ -f "/tmp/Postal2.ini" ]; then
    echo "Using custom Postal2.ini..."
    cp -f /tmp/Postal2.ini ${POSTAL2_DIR}/System/Postal2.ini
fi

cp -f ${POSTAL2_DIR}/System_NC_Compile/* ${POSTAL2_DIR}/System/ 2>/dev/null || true

echo "Starting Postal 2 server..."

# Configure Wine for headless operation
export DISPLAY=:0
export WINEDEBUG=fixme-all
export WINEPREFIX=/home/dude/.wine
export XDG_RUNTIME_DIR=/tmp/runtime-dude
mkdir -p $XDG_RUNTIME_DIR

# Initialize Wine in headless mode
winecfg -v win7 &>/dev/null || true

# Change to the Postal 2 directory
cd ${POSTAL2_DIR}/System
echo "Running Postal 2 server directly..."

exec wine UCC.exe server NicksCoopMapLoader.fuk?Game=NicksCoop.CoopGameInfo ini=Postal2CoOp.ini log=Server.log