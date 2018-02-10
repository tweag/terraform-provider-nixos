package nixos

import (
	"crypto/sha1"
	"encoding/hex"
	"fmt"
	"io/ioutil"
	"os"
	"path"

	"github.com/hashicorp/terraform/helper/schema"
)

func resourceNixOSNode() *schema.Resource {
	return &schema.Resource{
		Create: resourceNixOSFileCreate,
		Update: resourceNixOSFileCreate,
		Read:   resourceNixOSFileRead,
		Delete: resourceNixOSFileDelete,
		Schema: map[string]*schema.Schema{
			"node_name": &schema.Schema{
				Type:        schema.TypeString,
				Description: "Name of the system to represent",
				ForceNew:    true,
				Required:    true,
			},
			"ip": &schema.Schema{
				Type:        schema.TypeString,
				Description: "IP of the system to represent",
				ForceNew:    false,
				Required:    true,
			},
			"nix": &schema.Schema{
				Type:        schema.TypeString,
				Description: "IP of the system to represent",
				ForceNew:    false,
				Required:    true,
			},
			"filename": &schema.Schema{
				Type:        schema.TypeString,
				Description: "Path to the node's nix file",
				ForceNew:    true,
				Computed:    true,
			},
		},
	}
}

func resourceNixOSFileRead(d *schema.ResourceData, cfg interface{}) error {
	// If the output file doesn't exist, mark the resource for creation.
	outputPath := path.Join(cfg.(string), d.Get("node_name").(string)) + ".nix"
	if _, err := os.Stat(outputPath); os.IsNotExist(err) {
		d.SetId("")
		return nil
	}

	// Verify that the content of the destination file matches the content we
	// expect. Otherwise, the file might have been modified externally and we
	// must reconcile.
	outputContent, err := ioutil.ReadFile(outputPath)
	if err != nil {
		return err
	}

	outputChecksum := sha1.Sum([]byte(outputContent))
	if hex.EncodeToString(outputChecksum[:]) != d.Id() {
		d.SetId("")
		return nil
	}

	return nil
}

func resourceNixOSFileCreate(d *schema.ResourceData, cfg interface{}) error {
	destination := path.Join(cfg.(string), d.Get("node_name").(string)) + ".nix"
	d.Set("filename", string(destination))
	content := fmt.Sprintf(`{
  terraform.ip = "%s";
  terraform.name = "%s";
  %s
}
`,
		d.Get("ip").(string),
		d.Get("node_name").(string),
		d.Get("nix").(string),
	)

	return writeToFile(d, destination, content)
}

func writeToFile(d *schema.ResourceData, destination string, content string) error {
	destinationDir := path.Dir(destination)
	if _, err := os.Stat(destinationDir); err != nil {
		if err := os.MkdirAll(destinationDir, 0777); err != nil {
			return err
		}
	}

	if err := ioutil.WriteFile(destination, []byte(content), 0644); err != nil {
		return err
	}

	checksum := sha1.Sum([]byte(content))
	d.SetId(hex.EncodeToString(checksum[:]))

	return nil
}

func resourceNixOSFileDelete(d *schema.ResourceData, cfg interface{}) error {
	destination := path.Join(cfg.(string), d.Get("node_name").(string)) + ".nix"
	os.Remove(destination)
	return nil
}
