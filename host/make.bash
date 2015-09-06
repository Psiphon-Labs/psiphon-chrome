#!/usr/bin/env bash

set -e
set -exv # verbose output for testing

if [ ! -f make.bash ]; then
  echo 'make.bash must be run from $GOPATH/src/github.com/Psiphon-Labs/psiphon-chrome/host'
  exit 1
fi

CGO_ENABLED=1

# Make sure we have our dependencies
echo -e "go-getting dependencies...\n"
GOOS=linux go get -d -v ./...
GOOS=windows go get -d -v ./...
GOOS=darwin go get -d -v ./...

EXE_BASENAME="psiphon-native-messaging-host"
BUILDDATE=$(date --iso-8601=seconds)
BUILDREPO=$(git config --get remote.origin.url)
BUILDREV=$(git rev-parse HEAD)

LDFLAGS="\
-X github.com/Psiphon-Labs/psiphon-tunnel-core/psiphon.buildDate=$BUILDDATE \
-X github.com/Psiphon-Labs/psiphon-tunnel-core/psiphon.buildRepo=$BUILDREPO \
-X github.com/Psiphon-Labs/psiphon-tunnel-core/psiphon.buildRev=$BUILDREV \
"
echo -e "LDFLAGS=$LDFLAGS\n"

if [ ! -d bin ]; then
  mkdir bin
  mkdir bin/windows
  mkdir bin/linux
  mkdir bin/darwin
fi

echo -e "\nBuilding windows-i686..."
CC=/usr/bin/i686-w64-mingw32-gcc \
  gox -verbose -ldflags "$LDFLAGS" -osarch windows/386 -output bin/windows/${EXE_BASENAME}-i686
upx --best bin/windows/${EXE_BASENAME}-i686.exe

echo -e "\nNot Building windows-x86_64"
#CC=/usr/bin/x86_64-w64-mingw32-gcc \
#  gox -verbose -ldflags "$LDFLAGS" -osarch windows/amd64 -output bin/windows/${EXE_BASENAME}-x86_64
#upx --best bin/windows/${EXE_BASENAME}-x86_64.exe

echo -e "\nBuilding linux-i686..."
CFLAGS=-m32 \
  gox -verbose -ldflags "$LDFLAGS" -osarch linux/386 -output bin/linux/${EXE_BASENAME}-i686
goupx --best bin/linux/${EXE_BASENAME}-i686

echo -e "\nNot Building linux-x86_64..."
#  gox -verbose -ldflags "$LDFLAGS" -osarch linux/amd64 -output bin/linux/${EXE_BASENAME}-x86_64
#goupx --best bin/linux/${EXE_BASENAME}-x86_64

CGO_ENABLED=0
echo -e "\nBuilding darwin-x86_64..."
  gox -verbose -ldflags "$LDFLAGS" -osarch darwin/amd64 -output bin/darwin/${EXE_BASENAME}-x86_64
# It doesn't seem as though Darwin binaries can be UPX'ed in this way?
#upx --best bin/darwin/${EXE_BASENAME}-x86_64
