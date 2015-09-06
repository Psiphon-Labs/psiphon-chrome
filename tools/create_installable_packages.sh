#!/bin/bash

BASE_PATH="$( cd "$(dirname "$0")/../" ; pwd -P )"
cd $BASE_PATH

NAME="psiphon-chrome"
VERSION="0.0.1"
VENDOR="Psiphon Inc."
MAINTAINER="Psiphon Inc. <info@psiphon.ca>"
URL="https://psiphon3.com"
DESCRIPTION="Chrome Native Messaging Host and Extension for using the Psiphon Circumvention System from within the browser\n"
EXTENSION_ID="gnalljkfdmkhinjcipgjjehclbpagega"

MANIFEST_FILE="ca.psiphon.chrome.json"
EXECUTABLE_NAME="psiphon-native-messaging-host"

create_external_install_preferences () {
  cat << EOF > /tmp/$EXTENSION_ID.json
{"external_update_url": "https://clients2.google.com/service/update2/crx"}
EOF
}

create_postinstall_script () {
  cat << EOF > /tmp/post_install.sh
#!/bin/bash
chmod -R a+rx /opt/PsiphonChrome

if [ $(uname -s) == "Linux" ]; then
  MANIFEST_DESTINATION=~/.config/google-chrome/NativeMessagingHosts
  UPDATE_FILE_DESTINATION=/opt/google/chrome/extensions
elif [ $(uname -s) == "Darwin" ]; then
  MANIFEST_DESTINATION=~/Library/Application\ Support/Google/Chrome/NativeMessagingHosts/$MANIFEST_FILE
  UPDATE_FILE_DESTINATION=~/Library/Application\ Support/Google/Chrome/External\ Extensions/${EXTENSION_ID}.json
fi

if [ ! -d $MANIFEST_DESTINATION ]; then
  mkdir -p $MANIFEST_DESTINATION
fi
cp /opt/PsiphonChrome/$MANIFEST_FILE $MANIFEST_DESTINATION

if [ ! -d $UPDATE_FILE_DESTINATION ]; then
  mkdir -p $UPDATE_FILE_DESTINATION
fi
cp /opt/PsiphonChrome/${EXTENSION_ID}.json $UPDATE_FILE_DESTINATION

chown -R $USER $MANIFEST_DESTINATION
chown -R $USER $UPDATE_FILE_DESTINATION

EOF
}

package_for_linux () {
  #BUILD_ARCHITECHTURES=( "x86_64" "i686" )
  BUILD_ARCHITECHTURES=( "i686" )
  BUILD_TARGETS=( "deb" "rpm" )

  for ARCH in "${BUILD_ARCHITECHTURES[@]}"; do
    for TARGET in "${BUILD_TARGETS[@]}"; do
      fpm \
      -s dir \
      -t $TARGET \
      -n $NAME \
      --after-install /tmp/post_install.sh \
      --architecture $ARCH \
      --version $VERSION \
      --vendor "$VENDOR" \
      --maintainer "$MAINTAINER" \
      --url "$URL" \
      --description "${DESCRIPTION}" \
      host/bin/linux/$EXECUTABLE_NAME-$ARCH=/opt/PsiphonChrome/$EXECUTABLE_NAME \
      host/$MANIFEST_FILE=/opt/PsiphonChrome/$MANIFEST_FILE \
      /tmp/${EXTENSION_ID}.json=/opt/PsiphonChrome/${EXTENSION_ID}.json
    done
  done
}

package_for_osx () {
  fpm \
  -s dir \
  -t osxpkg \
  -n $NAME \
  --after-install /tmp/post_install.sh \
  --version $VERSION \
  --vendor "$VENDOR" \
  --maintainer "$MAINTAINER" \
  --url "$URL" \
  --description "${DESCRIPTION}" \
  host/bin/darwin/$EXECUTABLE_NAME-x86_64=/opt/PsiphonChrome/$EXECUTABLE_NAME \
  host/$MANIFEST_FILE=/opt/PsiphonChrome/$MANIFEST_FILE \
  /tmp/${EXTENSION_ID}.json=/opt/PsiphonChrome/${EXTENSION_ID}.json
}

echo "Starting package creation at $(date)"

TARGET=$1
case $TARGET in
  linux)
    echo "..Target 'linux' selected. Packaging"
    create_external_install_preferences
    create_postinstall_script

    package_for_linux
    ;;
  osx)
    echo "..Target 'osx' selected. Packaging"
    create_external_install_preferences
    create_postinstall_script

    package_for_osx
    ;;
  all)
    echo "..Target 'all' selected. Packaging"
    echo "...Linux"
    package_for_linux
    echo "...OSX"
    package_for_osx
    ;;
  *)
    echo "Invalid target. 'linux', 'osx', and 'all' are the only currently supported targets. Passed target was: '${TARGET}', aborting"
    exit 1
    ;;
esac

echo "Ending package creation at $(date)"
