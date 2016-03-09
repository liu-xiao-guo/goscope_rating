#!/bin/bash

# Function that executes a given command and compares its return command with a given one.
# In case the expected and the actual return codes are different it exits
# the script.
# Parameters:
#               $1: Command to be executed (string)
#               $2: Expected return code (number), Can be not defined.
function executeCommand()
{
    # gets the command
    CMD=$1
    # sets the return code expected
    # if it's not definedset it to 0
    OK_CODE=$2
    if [ -n $2 ]
    then
        OK_CODE=0
    fi
    # executes the command
    ${CMD}

    # checks if the command was executed successfully
    RET_CODE=$?
    if [ $RET_CODE -ne $OK_CODE ]
    then
        echo "ERROR executing command: \"$CMD\""
        echo "Exiting..."
        exit 1
    fi
}


# ******************************************************************************
# *                                   MAIN                                     *
# ******************************************************************************

if [ $# -ne 2 ]
then
    echo "usage: $0 FRAMEWORK_CHROOT SERIES_CHROOT"
    exit 1
fi

CHROOT=$1
SERIES=$2

sudo click chroot -aarmhf -f$CHROOT -s $SERIES create
sudo click chroot -aarmhf -f$CHROOT -s $SERIES maint apt-get install golang-go golang-go-linux-arm golang-go-dbus-dev golang-go-xdg-dev golang-gocheck-dev golang-gosqlite-dev golang-uuid-dev libgcrypt20-dev:armhf libglib2.0-dev:armhf libwhoopsie-dev:armhf libdbus-1-dev:armhf libnih-dbus-dev:armhf libsqlite3-dev:armhf crossbuild-essential-armhf

echo "Executing go get launchpad.net/go-unityscopes/v2 ...."
GOPATH=`pwd` go get launchpad.net/go-unityscopes/v2
echo "Done."



