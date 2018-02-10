package main

import (
	"github.com/hashicorp/terraform/plugin"
	"github.com/tweag/terraform-provider-nixos/nixos"
)

func main() {
	plugin.Serve(&plugin.ServeOpts{
		ProviderFunc: nixos.Provider})
}
