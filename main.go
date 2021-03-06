package main

import (
	"fmt"
	"os"

	"github.com/ksonnet/kubecfg/cmd"
)

// Version is overridden using `-X main.version` during release builds
var version = "(dev build)"

func main() {
	cmd.Version = version

	if err := cmd.RootCmd.Execute(); err != nil {
		fmt.Fprintln(os.Stderr, "Error:", err)
		os.Exit(1)
	}
}
