#!/bin/bash

try_fix_floppy () {
    echo -e "\e[7mFormatting drive\e[0m"
    sudo ufiformat -f $2 -v $1 || return 1
    echo -e "\e[7mMaking file system\e[0m"
    sudo mkfs -t vfat $1

    echo -e "\e[7mMounting drive\e[0m"
    sudo mount -t vfat -o rw,users,umask=000,exec $1 /mnt/floppy || return 1
    echo -e "\e[7mCreating test file\e[0m"
    touch /mnt/floppy/test.txt || return 1
    echo -e "\e[7mWriting test file\e[0m"
    echo "test abc @ xyz" >> /mnt/floppy/test.txt || return 1
    echo -e "\e[7mPrinting test file\e[0m"
    cat /mnt/floppy/test.txt || return 1
    echo -e "\e[7mPrinting mounted dir - expect only test.txt\e[0m"
    eza /mnt/floppy/ -la || return 1
    echo -e "\e[7mRemoving test file\e[0m"
    rm /mnt/floppy/test.txt || return 1
    echo -e "\e[7mPrinting mounted dir - expect nothing\e[0m"
    eza /mnt/floppy/ -la || return 1
    echo -e "\e[7mUnmounting drive\e[0m"
    sudo umount $1 || return 1

    echo -e "\e[7mSuccessfully repaired drive\e[0m"
    return 0
}

if [ "$1" == "-h" ] || [ "$1" == "--help" ]; then
    echo -e "floppy-fix.sh DRIVE DENSITY\n    DRIVE   - /dev/sda, /dev/sdb\n    DENSITY - 1440 HD, 720 SD"
    exit 0
fi

try_fix_floppy $1 $2 && aplay ~/.dot/data/success.wav || aplay ~/.dot/data/error.wav
