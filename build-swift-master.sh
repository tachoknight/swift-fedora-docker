#!/bin/bash

if [ -z "$1" ]
then
      	echo "$0 <image id>"
	exit 1
else
	FEDORAIMAGE=$1
fi

START_TS=`date`

FEDORAIMAGE=$1

# Create a directory to hold the results
BUILD_DIR=$(mktemp -d "${PWD}/b-$FEDORAIMAGE-XXXXXXXXXX")
chmod 777 $BUILD_DIR

# Get the latest source in the right spot...
# NOTE! We get the source *inside* the container. Why? 
# Because the python script used to get the source 
# (swift/utils/update-checkout) makes some determinations
# of what to get based on the platform it's running on.
# That's fine if we're in an all-Linux environment, but
# if you're using Docker on a Mac it will base its
# checkout manifest on the wrong platform, and won't 
# grab everything (e.g. ICU) that the container needs
# to build successfully.
SOURCE_DIR=$(mktemp -d "${PWD}/s-$FEDORAIMAGE-XXXXXXXXXX")
chmod 777 $SOURCE_DIR

echo Okay, here we go! Running from image $FEDORAIMAGE
docker run \
--security-opt=no-new-privileges  \
--cap-add=SYS_PTRACE \
--security-opt seccomp=unconfined \
--user 1000:1000 \
-v $SOURCE_DIR:/source:z \
-v $BUILD_DIR:/home/build-user:z \
-w /home/build-user/ \
$FEDORAIMAGE \
/bin/bash -lc "cd /source; git clone https://github.com/apple/swift.git swift; ./swift/utils/update-checkout --clone; ./swift/utils/build-script --preset buildbot_linux,no_test install_destdir=/home/build-user/builds installable_package=/home/build-user/swift-master.tar.gz > /home/build-user/build-output.txt"

echo "*** D O N E ***"
echo Source is in $SOURCE_DIR
echo Builds \(if any\) should be in $BUILD_DIR

echo Started:_____$START_TS
echo Ended:_______`date`
