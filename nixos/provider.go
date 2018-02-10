package nixos

import (
	"github.com/hashicorp/terraform/helper/schema"
	"github.com/hashicorp/terraform/terraform"
)

func Provider() terraform.ResourceProvider {
	return &schema.Provider{
		ConfigureFunc: providerConfigure,
		Schema: map[string]*schema.Schema{
			"root": &schema.Schema{
				Type:        schema.TypeString,
				Description: "IP of the system to represent",
				ForceNew:    true,
				Required:    true,
			},
		},
		ResourcesMap: map[string]*schema.Resource{
			"nixos_node": resourceNixOSNode(),
		},
	}
}

func providerConfigure(d *schema.ResourceData) (interface{}, error) {
	return d.Get("root"), nil
}
