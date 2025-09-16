#!/usr/bin/env bash
set -e

POSTAL2_DIR="/home/dude/game"

if [ ! -f "${POSTAL2_DIR}/.basegame-imported" ]; then
    echo "Initializing base game files..."
    cp -rf /tmp/postal2-base/* ${POSTAL2_DIR}/
    touch ${POSTAL2_DIR}/.basegame-imported
else
    echo "Base game files already imported, skipping..."
fi

if [ ! -f "${POSTAL2_DIR}/.overrides-imported" ]; then
    echo "Initializing override files..."
    
    echo "Downloading override files..."
    mkdir -p /tmp/postal2-overrides/
    wget --header="User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36" \
         -O /tmp/postal2-overrides/overrides.zip \
         https://www.moddb.com/downloads/mirror/239722/122/c07eeed865b339b4ff123f45cd3cc495
    unzip /tmp/postal2-overrides/overrides.zip -d /tmp/postal2-overrides/ 2>/dev/null
    rm /tmp/postal2-overrides/overrides.zip 2>/dev/null

    echo "Copying override files..."
    cp -rf /tmp/postal2-overrides/* ${POSTAL2_DIR}/
    rm ${POSTAL2_DIR}/_source_15-10-2022.zip 2>/dev/null || true

    echo "Extracting System_NC_Compile files..."
    unzip ${POSTAL2_DIR}/_def-system-compile.zip -d ${POSTAL2_DIR}/System_NC_Compile 2>/dev/null
    rm ${POSTAL2_DIR}/_def-system-compile.zip 2>/dev/null || true
    mv ${POSTAL2_DIR}/System_NC_Compile/* ${POSTAL2_DIR}/System/ 2>/dev/null

    touch ${POSTAL2_DIR}/.overrides-imported
else
    echo "Override files already imported, skipping..."
fi

if [ ! -f "${POSTAL2_DIR}/.config-imported" ]; then
    echo "Initializing custom Postal2.ini"

    wget -O /tmp/Postal2.ini https://gist.githubusercontent.com/Koncord/5ea0d1daec8f1c6185eb72d4ad09eca0/raw/366bc04ff39dea8ef6f02aa89a0e83208f49e8be/Postal2.ini
    cp -f /tmp/Postal2.ini ${POSTAL2_DIR}/System/Postal2.ini 2>/dev/null

    rm /tmp/Postal2.ini 2>/dev/null || true

    echo "Applying environment variable overrides to Postal2.ini"
    if { [ -n "$POSTAL_ADMIN_USERNAME" ] && [ -z "$POSTAL_ADMIN_PASSWORD" ]; } || { [ -z "$POSTAL_ADMIN_USERNAME" ] && [ -n "$POSTAL_ADMIN_PASSWORD" ]; }; then
        echo "Both POSTAL_ADMIN_USERNAME and POSTAL_ADMIN_PASSWORD must be set or both must be empty."
        exit 1
    fi

    if [ -n "$POSTAL_ADMIN_USERNAME" ] && [ -n "$POSTAL_ADMIN_PASSWORD" ]; then
        sed -i "s/^AdminUsername=.*$/AdminUsername=$POSTAL_ADMIN_USERNAME/" ${POSTAL2_DIR}/System/Postal2.ini
        sed -i "s/^AdminPassword=.*$/AdminPassword=$POSTAL_ADMIN_PASSWORD/" ${POSTAL2_DIR}/System/Postal2.ini
    fi

    if [ -n "$POSTAL_SERVER_PASSWORD" ]; then
        sed -i "s/^GamePassword=.*$/GamePassword=$POSTAL_SERVER_PASSWORD/" ${POSTAL2_DIR}/System/Postal2.ini
    fi


    touch ${POSTAL2_DIR}/.config-imported
else
    echo "Custom Postal2.ini already copied, skipping..."
fi

echo "Configuring wine..."
# Wine config
export DISPLAY=:0
export WINEDEBUG=fixme-all
export WINEPREFIX=/home/dude/.wine
export XDG_RUNTIME_DIR=/tmp/runtime-dude
mkdir -p $XDG_RUNTIME_DIR

winecfg -v win7 &>/dev/null || true

cd ${POSTAL2_DIR}/System
echo "Running Postal 2 server"

exec wine UCC.exe server NicksCoopMapLoader.fuk?Game=NicksCoop.CoopGameInfo ini=Postal2CoOp.ini log=Server.log