#!/bin/bash

if [ -z "$1" ]
then
      	echo "$0 <image id>"
	return 1
else
	FEDORAIMAGE=$1
fi

START_TS=`date`

FEDORAIMAGE=$1

# Create a directory to hold the results
BUILD_DIR=$(mktemp -d -t b-$FEDORAIMAGE-XXXXXXXXXX --tmpdir=$PWD)

# Get the latest source in the right spot...
echo Getting latest source...
SOURCE_DIR=$(mktemp -d -t s-$FEDORAIMAGE-XXXXXXXXXX --tmpdir=$PWD)
pushd $SOURCE_DIR
git clone https://github.com/apple/swift.git swift
./swift/utils/update-checkout --clone --scheme master
popd

echo Okay, here we go! Running from image $FEDORAIMAGE
docker run \
--security-opt=no-new-privileges  \
--cap-add=SYS_PTRACE \
--security-opt seccomp=unconfined \
-v $SOURCE_DIR:/source:z \
-v $BUILD_DIR:/home/build-user:z \
-w /home/build-user/ \
$FEDORAIMAGE \
/bin/bash -lc "cp -r /source/* /home/build-user/; ./swift/utils/build-script --preset buildbot_linux install_destdir=/home/build-user/builds installable_package=/home/build-user/swift-master.tar.gz"

echo *** D O N E ***
echo Source is in $SOURCE_DIR
echo Builds \(if any\) should be in $BUILD_DIR

echo Started:_____$START_TS
echo Ended:_______`date`
