#!/bin/bash

if [ -z "$1" ]
then
      	echo "$0 <image id>"
	return 1
else
	FEDORAIMAGE=$1
fi

FEDORAIMAGE=$1

# Clear away any previous builds
echo Clearing build directory...
pushd ./builds
rm -rf *
popd

# Get the latest source in the right spot...
echo Getting latest source...
pushd ./source
git clone https://github.com/apple/swift.git swift
./swift/utils/update-checkout --clone --scheme master
popd

echo Okay, here we go! Running from image $FEDORAIMAGE
docker run \
--security-opt=no-new-privileges  \
--cap-add=SYS_PTRACE \
--security-opt seccomp=unconfined \
-v $PWD/source:/source:z \
-v $PWD/builds:/home/build-user:z \
-w /home/build-user/ \
$FEDORAIMAGE \
/bin/bash -lc "cp -r /source/* /home/build-user/; ./swift/utils/build-script --preset buildbot_linux install_destdir=/home/build-user/builds installable_package=/home/build-user/swift-master.tar.gz"
