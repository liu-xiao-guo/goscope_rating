#!/bin/bash

#
# This file cleans all of the intermediate files produced during the compilation. For each project
# a developer needs to customize the variables
#     SCOPE_NAME
# 	  DEVELOPER_NAME
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

SCOPE_NAME=goscope
DEVELOPER_NAME=liu-xiao-guo

FILE_NAME="${SCOPE_NAME}.${DEVELOPER_NAME}"

echo -n "Removing ${FILE_NAME} directory... "
executeCommand "rm -rf ./${FILE_NAME}"
echo "Done"

echo -n "Removing ${FILE_NAME}_${SCOPE_NAME}.ini ..."
executeCommand "rm -f ${FILE_NAME}_${SCOPE_NAME}.ini"
echo "Done"

echo -n "Removing ${FILE_NAME} ..."
executeCommand "rm -f ${FILE_NAME}"
echo "Done"

echo -n "Removing pkg directory ..."
executeCommand "rm -rf pkg"
echo "Done"
