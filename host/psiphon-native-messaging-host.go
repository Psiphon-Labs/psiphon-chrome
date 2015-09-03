package main

import (
	"bufio"
	"bytes"
	"encoding/binary"
	"encoding/json"
	"fmt"
	"io"
	"os"
	"runtime"
	"sync"

	"github.com/Psiphon-Labs/psiphon-tunnel-core/psiphon"
)

type PsiphonPipe struct {
	r *io.PipeReader
	w *io.PipeWriter
}

var psiphonPipe PsiphonPipe

var stdoutWriter io.Writer
var stderrWriter io.Writer
var psiphonOutputWriter io.Writer
var shutdownBroadcast chan struct{}
var controllerWaitGroup *sync.WaitGroup

func sendMessage(message []byte) {
	length := make([]byte, 4)
	binary.LittleEndian.PutUint32(length, uint32(len(message)))

	stdoutWriter.Write(length)
	stdoutWriter.Write(message)
}

func main() {
	canExit := make(chan bool)

	psiphonPipe.r, psiphonPipe.w = io.Pipe()

	stderrWriter = os.Stderr
	stdoutWriter = os.Stdout

	mainStdin := bufio.NewReader(os.Stdin)

	go func() {
		scanner := bufio.NewScanner(psiphonPipe.r)
		for scanner.Scan() {
			sendMessage(scanner.Bytes())
		}
		if err := scanner.Err(); err != nil {
			fmt.Fprintf(stderrWriter, "error scanning lines from psiphonPipe.r: %s\n", err)
		}
	}()
	go func() {
		for {
			messageLengthBytes := make([]byte, 4)
			bytesRead, err := mainStdin.Read(messageLengthBytes)
			if err != nil {
				fmt.Fprintf(stderrWriter, "error reading message length: %s\n", err)
				break
			}
			if bytesRead == 0 {
				fmt.Fprintf(stderrWriter, "error reading byte array with message: array is empty\n")
				break
			}

			var messageLength int32
			tempBuffer := bytes.NewBuffer(messageLengthBytes)
			err = binary.Read(tempBuffer, binary.LittleEndian, &messageLength)
			if err != nil {
				fmt.Fprintf(stderrWriter, "error converting message length from bytes to int : %s\n", err)
				break
			}

			messageBytes := make([]byte, messageLength)
			bytesRead, err = mainStdin.Read(messageBytes)
			if err != nil {
				fmt.Fprintf(stderrWriter, "error reading message length: %s\n", err)
				break
			}

			var parsed map[string]interface{}
			err = json.Unmarshal(messageBytes, &parsed)
			if err != nil {
				fmt.Fprintf(stderrWriter, "error unmarshalling json: %s\n", err)
				break
			}

			if parsed["psi"] == "connect" {
				runPsiphon()
			}

			if parsed["psi"] == "disconnect" {
				close(shutdownBroadcast)
				controllerWaitGroup.Wait()
			}

		}

		// allow main to finish
		canExit <- true
	}()

	<-canExit
}

// {{{ Run Psiphon
func runPsiphon() {
	// Initialize default Notice output
	psiphon.SetNoticeOutput(psiphonPipe.w)

	//TODO: Embedded server entries

	// {{{ Load and parse config file
	config, err := psiphon.LoadConfig(PSIPHON_CONFIG)
	if err != nil {
		psiphon.NoticeError("error processing configuration file: %s", err)
		os.Exit(1)
	}

	// TODO: There is probably a much better way of doing this...
	// The CWD of this file when launched by Chrome will be the Chrome install's directory
	// As a non-administrative user, you cannot write files to this directory.
	// No files means no sqlite db, and therefore no tunnel-core.
	if runtime.GOOS == "windows" {
		config.DataStoreDirectory = os.Getenv("APPDATA") + "\\PsiphonChrome"
	}
	// }}}

	// {{{ Initialize data store

	err = psiphon.InitDataStore(config)
	if err != nil {
		psiphon.NoticeError("error initializing datastore: %s", err)
		os.Exit(1)
	}
	// }}}

	controller, err := psiphon.NewController(config)
	if err != nil {
		psiphon.NoticeError("error creating controller: %s", err)
		os.Exit(1)
	}

	shutdownBroadcast = make(chan struct{})
	controllerWaitGroup = new(sync.WaitGroup)
	controllerWaitGroup.Add(1)
	go func() {
		defer controllerWaitGroup.Done()
		controller.Run(shutdownBroadcast)
	}()
}

// }}}
