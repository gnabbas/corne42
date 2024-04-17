#!/bin/bash

if [[ $(/usr/bin/id -u) -ne 0 ]]; then
    echo "Not running as root"
    exit
fi

devicechecker='lsblk | grep 115.5G | awk '\''{print $1}'\'' | head -1'
mountchecker="mount | grep .flash_firmware/mnt"

flash(){
    while [ ! $(eval "$devicechecker") ]; do
        echo "waiting for $1 part to be connected"
        sleep 2
    done;

    if [ $(eval "$devicechecker") ]; then
        echo "$1 part connected!"

        mount /dev/$(eval "$devicechecker")1 .flash_firmware/mnt
        if [ "$(eval "$mountchecker")" ]; then
            echo "flashing firmware now..."
            cp .flash_firmware/*$1* .flash_firmware/mnt
        fi
        while [ "$(eval "$mountchecker")" ]; do
            echo "wating for flash to be completed"
            sleep 2
        done;
        echo "$1 part is flashed"
    else
        echo "$1 part is not connected. check manually"
        exit 1
    fi
}

umount .flash_firmware/mnt 2> /dev/null
rm -rf .flash_firmware 2> /dev/null
mkdir -p .flash_firmware/mnt
unzip $1 -d .flash_firmware

flash left
flash right

echo "flash completed - enjoy your new keyboard firmware!"
