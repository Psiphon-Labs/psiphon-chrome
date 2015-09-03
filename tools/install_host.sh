#!/bin/bash
set -e

cd $(dirname $(pwd))

DIR="$(dirname $(find $(pwd) -type f -name 'ca.psiphon.chrome.json'))"

if [ "$(uname -s)" == "Darwin" ]; then
  if [ "$(whoami)" == "root" ]; then
    TARGET_DIR="/Library/Google/Chrome/NativeMessagingHosts"
  else
    TARGET_DIR="$HOME/Library/Application Support/Google/Chrome/NativeMessagingHosts"
  fi
else
  if [ "$(whoami)" == "root" ]; then
    TARGET_DIR="/etc/opt/chrome/native-messaging-hosts"
  else
    TARGET_DIR="$HOME/.config/google-chrome/NativeMessagingHosts"
  fi
fi

HOST_NAME=ca.psiphon.chrome
EXECUTABLE=psiphon-native-messaging-host

# Create directory to store native messaging host.
mkdir -p "$TARGET_DIR"

# Copy native messaging host manifest.
cp "$DIR/$HOST_NAME.json" "$TARGET_DIR"

# Due to creating installable packages, the mainfest now uses a fixed path, and this code isn't needed
# Update host path in the manifest.
# HOST_PATH=$DIR/$EXECUTABLE
# ESCAPED_HOST_PATH=${HOST_PATH////\\/}
# sed -i -e "s/HOST_PATH/$ESCAPED_HOST_PATH/" "$TARGET_DIR/$HOST_NAME.json"

# Set permissions for the manifest so that all users can read it.
chmod a+r "$TARGET_DIR/$HOST_NAME.json"

echo "Native messaging host $HOST_NAME has been installed."
