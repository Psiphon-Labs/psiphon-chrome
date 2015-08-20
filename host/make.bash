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

EXE_BASENAME="psiphon-native-messaging-host"
BUILDDATE=$(date --iso-8601=seconds)
#BUILDREPO=$(git config --get remote.origin.url)
#BUILDREV=$(git rev-parse HEAD)
BUILDREPO="dev_build"
BUILDREV="Experimental_Dev_Build"
LDFLAGS="\
-X github.com/Psiphon-Labs/psiphon-tunnel-core/psiphon.buildDate $BUILDDATE \
-X github.com/Psiphon-Labs/psiphon-tunnel-core/psiphon.buildRepo $BUILDREPO \
-X github.com/Psiphon-Labs/psiphon-tunnel-core/psiphon.buildRev $BUILDREV \
"
echo -e "LDFLAGS=$LDFLAGS\n"

echo -e "\nBuilding windows-386..."
CC=/usr/bin/i686-w64-mingw32-gcc \
  gox -verbose -ldflags "$LDFLAGS" -osarch windows/386 -output ${EXE_BASENAME}
upx --best ${EXE_BASENAME}.exe

#echo -e "\nBuilding windows-amd64..."
#CC=/usr/bin/x86_64-w64-mingw32-gcc \
#  gox -verbose -ldflags "$LDFLAGS" -osarch windows/amd64 -output windows_amd64_${EXE_BASENAME}
#upx --best windows_amd64_${EXE_BASENAME}.exe

#echo -e "\nBuilding linux-amd64..."
#gox -verbose -ldflags "$LDFLAGS" -osarch linux/amd64 -output linux_amd64_${EXE_BASENAME}
#goupx --best linux_amd64_${EXE_BASENAME}

echo -e "\nBuilding linux-386..."
CFLAGS=-m32 \
  gox -verbose -ldflags "$LDFLAGS" -osarch linux/386 -output ${EXE_BASENAME}
goupx --best ${EXE_BASENAME}
