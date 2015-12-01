#!/bin/bash

BASE_PATH="$( cd "$(dirname "$0")/../" ; pwd -P )"
cd $BASE_PATH

NAME="psiphon-chrome"
VERSION="1"
ITERATION="2"
VENDOR="Psiphon Inc."
MAINTAINER="Psiphon Inc. <info@psiphon.ca>"
LICENSE="GPL-3"
URL="https://psiphon3.com"
DESCRIPTION="Use the Psiphon Circumvention System from within the Chrome browser!"
EXTENSION_ID="gnalljkfdmkhinjcipgjjehclbpagega"

MANIFEST_FILE="ca.psiphon.chrome.json"
EXECUTABLE_NAME="psiphon-native-messaging-host"

create_external_install_preferences () {
  cat << EOF > /tmp/$EXTENSION_ID.json
{"external_update_url": "https://clients2.google.com/service/update2/crx"}
EOF
}

create_after_install () {
  cat << EOF > /tmp/after_install.sh
#!/bin/bash
set -e

if [ -d /opt/PsiphonChrome ]; then
  chmod -R a+rwx /opt/PsiphonChrome
fi

if [ \$(uname -s) = "Linux" ]; then
  MANIFEST_DESTINATION=\$HOME/.config/google-chrome/NativeMessagingHosts
  UPDATE_FILE_DESTINATION=/opt/google/chrome/extensions
elif [ \$(uname -s) = "Darwin" ]; then
  MANIFEST_DESTINATION="\${HOME}/Library/Application Support/Google/Chrome/NativeMessagingHosts"
  UPDATE_FILE_DESTINATION="\${HOME}/Library/Application Support/Google/Chrome/External Extensions"
fi

if [ ! -d "\${MANIFEST_DESTINATION}" ]; then
  mkdir -p "\${MANIFEST_DESTINATION}"
fi
cp /opt/PsiphonChrome/$MANIFEST_FILE "\${MANIFEST_DESTINATION}"

if [ ! -d "\${UPDATE_FILE_DESTINATION}" ]; then
  mkdir -p "\${UPDATE_FILE_DESTINATION}"
fi
cp /opt/PsiphonChrome/${EXTENSION_ID}.json "\${UPDATE_FILE_DESTINATION}"

chown -R \$USER "\${MANIFEST_DESTINATION}"
chown -R \$USER "\${UPDATE_FILE_DESTINATION}"

EOF
}

create_after_remove () {
  cat << EOF > /tmp/after_remove.sh
#!/bin/bash
set -e

if [ \$(uname -s) = "Linux" ]; then
  MANIFEST_DESTINATION=\$HOME/.config/google-chrome/NativeMessagingHosts
  UPDATE_FILE_DESTINATION=/opt/google/chrome/extensions
elif [ \$(uname -s) = "Darwin" ]; then
  MANIFEST_DESTINATION="\${HOME}/Library/Application Support/Google/Chrome/NativeMessagingHosts"
  UPDATE_FILE_DESTINATION="\${HOME}/Library/Application Support/Google/Chrome/External Extensions"
fi

if [ -f \${MANIFEST_DESTINATION}/\${MANIFEST_FILE} ]; then
  rm "\${MANIFEST_DESTINATION}/\${MANIFEST_FILE}"
fi
if [ -f \${UPDATE_FILE_DESTINATION}/\${EXTENSION_ID}.json ]; then
  rm "\${UPDATE_FILE_DESTINATION}/\${EXTENSION_ID}.json"
fi
if [ -d /opt/PsiphonChrome ]; then
  rm -rf /opt/PsiphonChrome
fi

EOF
}

package_for_linux () {
  echo "....Checking for FPM in PATH"
  which fpm > /dev/null
  if [ $? != 0 ]; then
    echo ".....FPM not found in PATH, cannot create Linux installers, skipping"
    return 1
  fi

  #BUILD_ARCHITECHTURES=( "x86_64" "i686" )
  BUILD_ARCHITECHTURES=( "i686" )
  BUILD_TARGETS=( "deb" "rpm" )

  for ARCH in "${BUILD_ARCHITECHTURES[@]}"; do
    for TARGET in "${BUILD_TARGETS[@]}"; do
      fpm \
      -s dir \
      -t $TARGET \
      -n $NAME \
      --after-install /tmp/after_install.sh \
      --after-remove /tmp/after_remove.sh \
      --architecture all \
      --version $VERSION \
      --iteration $ITERATION \
      --vendor "$VENDOR" \
      --maintainer "$MAINTAINER" \
      --license "$LICENSE" \
      --url "$URL" \
      --description "${DESCRIPTION}" \
      --category "web" \
      --depends "google-chrome-beta|google-chrome-stable|google-chrome-unstable" \
      host/bin/linux/$EXECUTABLE_NAME-$ARCH=/opt/PsiphonChrome/$EXECUTABLE_NAME \
      host/$MANIFEST_FILE=/opt/PsiphonChrome/$MANIFEST_FILE \
      /tmp/${EXTENSION_ID}.json=/opt/PsiphonChrome/${EXTENSION_ID}.json
    done
  done

  mv *.rpm ./dist/
  mv *.deb ./dist/
}

package_for_osx () {
  if [ $(uname -s) != "Darwin" ]; then
    echo "....Packaging for OSX can only happen on an OSX machine, skipping"
    return 1
  fi

  # Create uninstall.pkg to clean everything up
  fpm \
  -s empty \
  -t osxpkg \
  -n $NAME-uninstall \
  --osxpkg-identifier-prefix ca.psiphon \
  --osxpkg-payload-free \
  --before-install /tmp/after_remove.sh \
  --version $VERSION \
  --iteration $ITERATION \
  --vendor "$VENDOR" \
  --maintainer "$MAINTAINER" \
  --license "$LICENSE" \
  --url "$URL" \
  --description "Uninstaller - ${DESCRIPTION}"

  fpm \
  -s dir \
  -t osxpkg \
  -n $NAME \
  --osxpkg-identifier-prefix ca.psiphon \
  --no-osxpkg-payload-free \
  --after-install /tmp/after_install.sh \
  --version $VERSION \
  --iteration $ITERATION \
  --vendor "$VENDOR" \
  --maintainer "$MAINTAINER" \
  --license "$LICENSE" \
  --url "$URL" \
  --description "${DESCRIPTION}" \
  host/bin/darwin/$EXECUTABLE_NAME-x86_64=/opt/PsiphonChrome/$EXECUTABLE_NAME \
  host/$MANIFEST_FILE=/opt/PsiphonChrome/$MANIFEST_FILE \
  /tmp/${EXTENSION_ID}.json=/opt/PsiphonChrome/${EXTENSION_ID}.json \
  $NAME-uninstall-${VERSION}.pkg=/opt/PsiphonChrome/uninstall.pkg

  # Uninstaller is packaged into installer and dropped in /opt/PsiphonChrome, remove this redundant one
  rm $NAME-uninstall-${VERSION}.pkg
  mv *.pkg ./dist/
}

package_for_windows () {
  echo "....Checking for NSIS in PATH"
  which makensis > /dev/null
  if [ $? != 0 ]; then
    echo ".....NSIS not found in PATH, cannot create Windows installer, skipping"
    return 1
  fi

  makensis tools/nsis/nsis-generate.nsi
  mv tools/nsis/*.exe ./dist/
}

echo "Starting package creation at $(date)"

echo "..Creating External Install Preferences JSON"
create_external_install_preferences
echo "..Creating post-installation script"
create_after_install
echo "..Creating post-uninstallation script"
create_after_remove
echo "..Ensuring availablity of 'dist' directory for installers"
if [ ! -d dist ]; then
  mkdir dist
fi

echo "Beginning target selection"
TARGET=$1
case $TARGET in
  linux)
    echo "..'linux' selected. Packaging"
    package_for_linux
    ;;
  osx)
    echo "..'osx' selected. Packaging"
    package_for_osx
    ;;
  windows)
    echo "..'windows' selected. Packaging"
    package_for_windows
    ;;
  all)
    echo "..'all' selected. Packaging"
    echo "...Linux"
    package_for_linux
    echo "...OSX"
    package_for_osx
    echo "...Windows"
    package_for_windows
    ;;
  *)
    echo "Invalid target. 'linux', 'osx', 'windows' and 'all' are the only supported targets. Passed target was: '${TARGET}', aborting"
    exit 1
    ;;
esac

echo "..Setting execuatable bit on installers"
chmod -R +x dist/*

echo "..Cleaning up temporary files packaged into installers"
rm /tmp/${EXTENSION_ID}.json
rm /tmp/after_install.sh
rm /tmp/after_remove.sh

echo "Ending package creation at $(date)"
