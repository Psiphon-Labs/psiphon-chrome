##Psiphon Chrome Native Messaging Host

###Building with Docker

Note that you may need to use `sudo docker` below, depending on your OS.

Create the build image:
  1. Change to the directory containing the `Dockerfile`
  2. Run the command: `docker build --no-cache=true -t psichrome .` (this may take some time to complete)
  3. Once completed, verify that you see an image named `psichrome` when running: `docker images`

Run the build:

```bash
docker run --rm -v $(pwd):/go/src/github.com/Psiphon-Labs/psiphon-chrome psichrome /bin/bash -c 'cd /go/src/github.com/Psiphon-Labs/psiphon-chrome && ./make.bash'
```

When that command completes, the compiled binaries will be located in the current directory. The files will be named:
 - `psiphon-native-messaging-host.exe` (for Windows)
 - `psiphon-native-messaging-host` (for Linux)

If attempting to install the extension along with the now built native messaging host, return to the instructions in the [main README](../README.md))
