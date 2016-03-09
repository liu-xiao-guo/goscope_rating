#!/bin/bash

#
# This is the script to build and run the scope on desktop environment. 
# A developer needs to change the following variable according to your projectt
#　		SCOPE_NAME=goscope
#　		DEVELOPER_NAME=liu-xiao-guo
#
#

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

export GOPATH=`pwd`

SCOPE_NAME=goscope
DEVELOPER_NAME=liu-xiao-guo

FILE_NAME="${SCOPE_NAME}.${DEVELOPER_NAME}"

echo -n "Removing ${FILE_NAME} directory... "
executeCommand "rm -rf ./${FILE_NAME}"
echo "Done"

echo -n "Copying scope ini file... "
executeCommand "cp $SCOPE_NAME.ini ${FILE_NAME}_${SCOPE_NAME}.ini"
echo "Done"

echo -n "Setting scope name in ini file..."
executeCommand 'sed -i "s/%SCOPE_NAME%/${FILE_NAME}/g" ${FILE_NAME}_${SCOPE_NAME}.ini'
echo "Done"

echo -n "Building the scope"
executeCommand "go build -o ${FILE_NAME}"

echo -n "unity-scope-tool ${FILE_NAME}_${SCOPE_NAME}.ini"
unity-scope-tool ${FILE_NAME}_${SCOPE_NAME}.ini

