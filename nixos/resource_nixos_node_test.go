package nixos

import (
	"errors"
	"fmt"
	"io/ioutil"
	"os"
	"testing"

	r "github.com/hashicorp/terraform/helper/resource"
	"github.com/hashicorp/terraform/terraform"
)

func TestNixOSNode_Basic(t *testing.T) {
	var cases = []struct {
		path    string
		content string
		config  string
	}{
		{
			"nixos/foo.nix",
			`{
  terraform.ip = "1.2.3.4";
  terraform.name = "foo";
  roles.webnode.enable = true;
}
`,
			`
provider "nixos" {
  root = "./nixos/"
}
resource "nixos_node" "webnode" {
  node_name = "foo"
  ip = "1.2.3.4"
  nix = "roles.webnode.enable = true;"
}
`,
		},
	}

	for _, tt := range cases {
		r.UnitTest(t, r.TestCase{
			Providers: testProviders,
			Steps: []r.TestStep{
				{
					Config: tt.config,
					Check: func(s *terraform.State) error {
						content, err := ioutil.ReadFile(tt.path)
						if err != nil {
							return fmt.Errorf("config:\n%s\n,got: %s\n", tt.config, err)
						}
						if string(content) != tt.content {
							return fmt.Errorf("config:\n%s\ngot:\n%s\nwant:\n%s\n", tt.config, content, tt.content)
						}
						return nil
					},
				},
			},
			CheckDestroy: func(*terraform.State) error {
				if _, err := os.Stat(tt.path); os.IsNotExist(err) {
					return nil
				}
				return errors.New("nixos_node did not get destroyed")
			},
		})
	}
}
