#!/usr/bin/env bash
set -e

if [ ! -f make.bash ]; then
  echo 'make.bash must be run from $GOPATH/src/github.com/Psiphon-Labs/psiphon-chrome/host'
  exit 1
fi

EXE_BASENAME="psiphon-native-messaging-host"
BUILDDATE=$(date --iso-8601=seconds)
BUILDREPO=$(git config --get remote.origin.url)
BUILDREV=$(git rev-parse --short HEAD)

LDFLAGS="\
-X github.com/Psiphon-Labs/psiphon-tunnel-core/psiphon.buildDate=$BUILDDATE \
-X github.com/Psiphon-Labs/psiphon-tunnel-core/psiphon.buildRepo=$BUILDREPO \
-X github.com/Psiphon-Labs/psiphon-tunnel-core/psiphon.buildRev=$BUILDREV \
"

echo "Variables for ldflags:"
echo " Build date: ${BUILDDATE}"
echo " Build repo: ${BUILDREPO}"
echo " Build revision: ${BUILDREV}"
echo ""

echo "getting project dependencies (via go get)"
GOOS=linux go get -d ./...
GOOS=windows go get -d ./...
GOOS=darwin go get -d ./...

echo "Setting up 'bin' directory for compiled binaries"
if [ ! -d bin ]; then
  mkdir bin
  mkdir bin/windows
  mkdir bin/linux
  mkdir bin/darwin
fi

echo "Setting up 'dist' directory for distributable installers"
if [ ! -d ../dist ]; then
  mkdir ../dist
fi

# Windows requires CGO due to sqlite. OpenSSL will likely eventually require CGO everywhere
echo "CGO Enabled"
CGO_ENABLED=1

echo "Building windows-i686..."
CC=/usr/bin/i686-w64-mingw32-gcc gox -verbose -ldflags "$LDFLAGS" -osarch windows/386 -output bin/windows/${EXE_BASENAME}-i686
upx --best bin/windows/${EXE_BASENAME}-i686.exe

echo "Not Building windows-x86_64"
#CC=/usr/bin/x86_64-w64-mingw32-gcc gox -verbose -ldflags "$LDFLAGS" -osarch windows/amd64 -output bin/windows/${EXE_BASENAME}-x86_64
#upx --best bin/windows/${EXE_BASENAME}-x86_64.exe

echo "CGO Disabled"
CGO_ENABLED=0

echo "Building linux-i686..."
CFLAGS=-m32 gox -verbose -ldflags "$LDFLAGS" -osarch linux/386 -output bin/linux/${EXE_BASENAME}-i686
goupx --best bin/linux/${EXE_BASENAME}-i686

echo "Not Building linux-x86_64..."
#gox -verbose -ldflags "$LDFLAGS" -osarch linux/amd64 -output bin/linux/${EXE_BASENAME}-x86_64
#goupx --best bin/linux/${EXE_BASENAME}-x86_64

echo "Building darwin-x86_64..."
gox -verbose -ldflags "$LDFLAGS" -osarch darwin/amd64 -output bin/darwin/${EXE_BASENAME}-x86_64
# Darwin binaries don't seem to be UPXable when built this way

# Create installable packages
echo "Creating installable packages"
cd ..
./tools/create_installable_packages.sh all
