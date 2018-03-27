package main

import (
	"flag"
	"fmt"
	"log"
	"os"

	"github.com/wiredcraft-ops/tool-kit/go/pkg"
)

var (
	version          = "master"
	mkansiblePath    string
	randompassLength int
)

const (
	versionFlag = "-v"
	helpFlag    = "-h"
	mkansible   = "mkansible"
	randompass  = "randompass"
)

func main() {

	mkansibleCmd := flag.NewFlagSet(mkansible, flag.ExitOnError)
	mkansibleCmd.StringVar(&mkansiblePath, "path", ".", "where to generate ansible scaffold")

	randompassCmd := flag.NewFlagSet(randompass, flag.ExitOnError)
	randompassCmd.IntVar(&randompassLength, "length", 10, "how many letters you want")

	if len(os.Args) == 1 {
		// no subcommand
		usage()
		os.Exit(1)
	}

	switch os.Args[1] {
	case mkansible:
		if err := mkansibleCmd.Parse(os.Args[2:]); err != nil {
			log.Fatalf("E! parse flag set failed: %v", err)
		}
		if err := pkg.Mkansible(mkansiblePath); err != nil {
			log.Fatalf("E! mkansible failed: %v", err)

		}
	case randompass:
		if err := randompassCmd.Parse(os.Args[2:]); err != nil {
			log.Fatalf("E! parse flag set failed: %v", err)
		}
		pass := pkg.RandomPass(randompassLength)
		fmt.Printf("%s\n", pass)
	case versionFlag:
		fmt.Printf("%s\n", version)
	case helpFlag:
		usage()
	default:
		flag.PrintDefaults()
	}

}

func usage() {

	msg := `
Usage : wcl [command] [args]

wcl mkansible

wcl randompass

Use wcl [command] -h to get more details
`
	fmt.Printf("%s\n", msg)
}
