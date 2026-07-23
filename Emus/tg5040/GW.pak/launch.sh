#!/bin/sh
# GW.pak - Game & Watch (gw-libretro) for NextUI / MinUI
# Platform: tg5040 (TrimUI Brick / Smart Pro)

EMU_EXE=gw

mydir=$(dirname "$0")
EMU_TAG=$(basename "$mydir" .pak)
ROM="$1"

mkdir -p "$BIOS_PATH/$EMU_TAG"
mkdir -p "$SAVES_PATH/$EMU_TAG"
mkdir -p "$CHEATS_PATH/$EMU_TAG"

HOME="$USERDATA_PATH"
cd "$HOME"

minarch.elf "$mydir/${EMU_EXE}_libretro.so" "$ROM" &> "$LOGS_PATH/$EMU_TAG.txt"
