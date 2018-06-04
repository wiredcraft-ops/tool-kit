package cmd

import (
	"fmt"

	"github.com/spf13/cobra"
)

func init() {
	RootCmd.AddCommand(editVars)
}

var editVars = &cobra.Command{
	Use:   "edit-vars",
	Short: "edit env groups vars in ansible playbooks",
	Run: func(cmd *cobra.Command, args []string) {
		fmt.Println("edit-vars")
	},
}
