##Psiphon Chrome
This is a Chrome app using native messaging

It currently:
  - Instantiates the tunnel core (with values from `host/embedded_values.go`)
  - Manages the Chrome proxy settings

In order to use this app you must:
  1. Copy `host/embedded_values.go.stub` to `host/embedded_values.go` and populate the configuration file appropriately
  2. Build the native messaging host (instructions in [host/README.md](host/README.md))
  3. Create the installer file for your system of choice (currently Linux and Windows are supported; OSX to come)

###To install:
####Create the installer:
#####On Windows:
 - Install [NSIS](http://nsis.sourceforge.net/Main_Page)
 - Right-Click on `nsis-generate` in `tools/nsis` and click "Compile NSIS Script" from the context menu
 - This will create `psiphon-chrome-installer.exe` in the current directory

#####On Linux:
 - Install the `fpm` ruby gem
 - Run the `create_installable_packages.sh` script in the `tools` directory
 - This will create 2 `.rpm` packages and 2 `.deb` pacakges (one each for 32 and 64 bit architectures)

Successful *installation* will install both the native messaging host binary, as well as the matched Chrome extension (you may need to restart Chrome)

Successful *uninstallation* will remove both the native messaging host binary, as well as the matched Chrome extension (you may need to restart Chrome)
