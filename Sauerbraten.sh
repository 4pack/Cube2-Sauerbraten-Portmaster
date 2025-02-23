#!/bin/bash

XDG_DATA_HOME=${XDG_DATA_HOME:-$HOME/.local/share}

if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
elif [ -d "$XDG_DATA_HOME/PortMaster/" ]; then
  controlfolder="$XDG_DATA_HOME/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

source $controlfolder/control.txt

#export PORT_32BIT="Y" # If using a 32 bit port
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"

get_controls

GAMEDIR=/$directory/ports/sauerbraten/
CONFDIR="$GAMEDIR/conf/"

mkdir -p "$GAMEDIR/conf"
mkdir -p "$GAMEDIR/conf/.sauerbraten"

cd $GAMEDIR

> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1

export XDG_DATA_HOME="$CONFDIR"
export LD_LIBRARY_PATH="$GAMEDIR/libs.${DEVICE_ARCH}:$LD_LIBRARY_PATH"
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export SAUER_DATA="$GAMEDIR/gamedata"
export SAUER_BIN=${SAUER_DATA}/bin_unix
export SAUER_OPTIONS="-q${CONFDIR}/.sauerbraten -w640 -h480"
#export TEXTINPUTINTERACTIVE="Y"

# if XDG Path does not work
# Use bind_directories to reroute that to a location within the ports folder.
bind_directories ~/.sauerbraten $GAMEDIR/conf/.sauerbraten 

# If using gl4es
if [ -f "${controlfolder}/libgl_${CFW_NAME}.txt" ]; then 
 source "${controlfolder}/libgl_${CFW_NAME}.txt"
else
 source "${controlfolder}/libgl_default.txt"
fi

$GPTOKEYB "${SAUER_BIN}/native_client" -c "./sauerbraten.gptk.$ANALOGSTICKS" &
pm_platform_helper "$GAMEDIR/gamedata/bin_unix/native_client"
./gamedata/bin_unix/native_client

pm_finish