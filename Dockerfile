FROM fedora

RUN dnf -y update && dnf install -y \
clang \
swig \
pkgconfig \
perl-podlators \
rsync \
python3 \
python3-devel \
python3-distro \
libbsd-devel \
libxml2-devel \
libsqlite3x-devel \
libblocksruntime-static \
libatomic-static \
libcurl-devel \
libuuid-devel \
libedit-devel \
libicu-devel \
ninja-build \
python3-six \
python27 \
cmake \
git \
python-unversioned-command \
make


