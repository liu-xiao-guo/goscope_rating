#!/bin/bash

#
#  usage: ./build.sh 
#         it builds project and produces the armhf click package
#         ./build.sh -d
#		  it builds the project and deploy it to the phone	
#  A developer needs to change the armhf names in the following script according tuo your project	
#

export GOPATH=`pwd`
go get launchpad.net/go-unityscopes/v2
./setup-chroot-go.sh ubuntu-sdk-15.04 vivid 
./build-click-package.sh goscope liu-xiao-guo ubuntu-sdk-15.04 vivid

if [ $# -eq 1 ]
then
	if [ $1 = "-d" ] 
	then
		echo "Start to deploy to the phone ..."
		adb push ./goscope.liu-xiao-guo/goscope.liu-xiao-guo_1.0.0_armhf.click /tmp
		adb shell "sudo -iu phablet pkcon --allow-untrusted install-local /tmp/goscope.liu-xiao-guo_1.0.0_armhf.click"
		exit 0
	fi
fi
