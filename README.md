##Psiphon Chrome
This is a Chrome app using native messaging

It currently:
  - Instantiates the tunnel core (with values from `host/embedded_values.go`)
  - Manages the Chrome proxy settings

In order to use this app (until cross platform installers are created) you must:
  1. Copy `host/embedded_values.go.stub` to `host/embedded_values.go` and populate the configuration file appropriately
  2. Build the native messaging host (instructions in [host/README.md](host/README.md))
  3. Install the native messaging host from the host directory (instructions below)
  4. Load the app from the `app`directory via `chrome://extensions` -> `Load unpacked extension...`

###To install the host:
####On Windows:
Run the `install_host.bat` script in the `tools` directory

This script installs the native messaging host for the current user
It creates a registry key: `HKEY_CURRENT_USER\SOFTWARE\Google\Chrome\NativeMessagingHosts\ca.psiphon.chrome`and sets its default value to the full path of `host\ca.psiphon.chrome-win.json`

If you want to install the native messaging host for all users, change `HKEY_CURRENT_USER` to `HKEY_LOCAL_MACHINE` when creating the registry key

####On Mac and Linux:
Run the `install_host.sh` script in the `tools` directory

By default the host is installed only for the user who runs the script, but if you run it with admin privileges (i.e. `sudo tools/install_host.sh`), then the host will be installed for all users


###To uninstall:
####Uninstalling the host:
  1. Run the `tools/uninstall_host.bat` or `tools/uninstall_host.sh` script to uninstall the host from Windows or Mac/Linux respectively

####Uninstalling the extension:
  1. Navigate to `chrome://extensions`
  2. Click the trash can icon on the right hand side of the `Psiphon` entry
