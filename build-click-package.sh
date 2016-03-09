#/bin/bash

# Function that executes a given command and compares its return command with a given one.
# In case the expected and the actual return codes are different it exits
# the script.
# Parameters:
#               $1: Command to be executed (string)
#               $2: Expected return code (number), may be undefined.
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
    eval ${CMD}

    # checks if the command was executed successfully
    RET_CODE=$?
    if [ $RET_CODE -ne $OK_CODE ]
    then
	echo ""
        echo "ERROR executing command: \"$CMD\""
        echo "Exiting..."
        exit 1
    fi
}

# ******************************************************************************
# *                                   MAIN                                     *
# ******************************************************************************

if [ $# -ne 4 ]
then
    echo "usage: $0 SCOPE_NAME DEVELOPER_NAME FRAMEWORK_CHROOT SERIES_CHROOT"
    exit 1
fi

SCOPE_NAME=$1
DEVELOPER_NAME=$2
CHROOT=$3
SERIES=$4

CURRENT_DIR=`pwd`

FILE_NAME="${SCOPE_NAME}.${DEVELOPER_NAME}"
MANIFEST_NAME="${SCOPE_NAME}.${DEVELOPER_NAME}"

echo -n "Removing ${FILE_NAME} directory... "
executeCommand "rm -rf ./${FILE_NAME}"
echo "Done"

echo -n "Creating clean ${FILE_NAME} directory... "
executeCommand "mkdir -p ${FILE_NAME}/${FILE_NAME}"
echo "Done"

echo -n "Copying scope ini file... "
executeCommand "cp $SCOPE_NAME.ini ${FILE_NAME}/${FILE_NAME}/${FILE_NAME}_${SCOPE_NAME}.ini"
echo "Done"

echo -n "Copying the logo file ... "
executeCommand "cp logo.jpg ${FILE_NAME}/${FILE_NAME}/logo.jpg"
echo "Done"

echo -n "Copying the icon file ... "
executeCommand "cp icon.jpg ${FILE_NAME}/${FILE_NAME}/icon.jpg"
echo "Done"

echo -n "Setting scope name in ini file..."
executeCommand 'sed -i "s/%SCOPE_NAME%/${FILE_NAME}/g" ${FILE_NAME}/${FILE_NAME}/${FILE_NAME}_${SCOPE_NAME}.ini'
echo "Done"

echo -n "Copying scope json files... "
executeCommand "cp *.json ${FILE_NAME}/"
echo "Done"

echo -n "Setting scope name in manifest file..."
executeCommand 'sed -i "s/%SCOPE_NAME%/${MANIFEST_NAME}/g" ${FILE_NAME}/manifest.json'
echo "Done"

echo -n "Cross compiling ${FILE_NAME}..."
executeCommand "click chroot -aarmhf -f$CHROOT -s $SERIES run CGO_ENABLED=1 GOARCH=arm GOARM=7 PKG_CONFIG_LIBDIR=/usr/lib/arm-linux-gnueabihf/pkgconfig:/usr/lib/pkgconfig:/usr/share/pkgconfig GOPATH=/usr/share/gocode/:$GOPATH CC=arm-linux-gnueabihf-gcc CXX=arm-linux-gnueabihf-g++ go build -ldflags '-extld=arm-linux-gnueabihf-g++' -o ${FILE_NAME}/${FILE_NAME}/${FILE_NAME}"
echo "Done"

executeCommand "cd ./${FILE_NAME}"

echo -n "Building click package ... "
executeCommand "click build ./"
echo "Done"

executeCommand "cd .."
