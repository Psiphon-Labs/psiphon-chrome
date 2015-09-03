#!/bin/bash

EXTENSION_ID=gnalljkfdmkhinjcipgjjehclbpagega

# TODO: Support multiple targets, read them in from $1
TARGET=linux

BASE_PATH="$( cd "$(dirname "$0")/../" ; pwd -P )"
cd $BASE_PATH

NAME="psiphon-chrome"
VERSION="0.0.1"
VENDOR="Psiphon Inc."
MAINTAINER="Psiphon Inc. <info@psiphon.ca>"
URL="https://psiphon3.com"
DESCRIPTIION="Chrome Native Messaging Host and Extension for using the Psiphon Circumvention System from within the browser"

MANIFEST_FILE="ca.psiphon.chrome.json"
EXECUTABLE_NAME="psiphon-native-messaging-host"

create_external_install_preferences () {
  cat << EOF > /tmp/$EXTENSION_ID.json
{"external_update_url": "https://clients2.google.com/service/update2/crx"}
EOF
}

package_for_linux () {
  create_external_install_preferences

  BUILD_ARCHITECHTURES=( "x86_64" "i686" )
  BUILD_TARGETS=( "deb" "rpm" )

  for ARCH in "${BUILD_ARCHITECHTURES[@]}"; do
    for TARGET in "${BUILD_TARGETS[@]}"; do
      fpm \
      -s dir \
      -t $TARGET \
      -n $NAME \
      --architecture $ARCH \
      --version $VERSION \
      --vendor "$VENDOR" \
      --maintainer "$MAINTAINER" \
      --url "$URL" \
      --description ${DESCRIPTION} \
      host/bin/linux/$EXECUTABLE_NAME-${ARCH}=/usr/local/bin/$EXECUTABLE_NAME \
      host/$MANIFEST_FILE=\$HOME/.config/google-chrome/NativeMessagingHosts/$MANIFEST_FILE \
      /tmp/${EXTENSION_ID}.json=/opt/google/chrome/extensions/${EXTENSION_ID}.json
    done
  done
}

echo "Starting package creation at $(date)"

case $TARGET in
  linux)
    echo "..Target 'linux' selected. Packaging"
    package_for_linux
    ;;
  *)
    echo "...'linux' is the only currently supported target. Passed target was: '${TARGET}', aborting"
    exit 1
    ;;
esac

echo "Ending package creation at $(date)"
