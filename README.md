Terraform Provider NixOS
==================

Maintainers
-----------

This provider plugin is an experiment.

Requirements
------------

-	[Terraform](https://www.terraform.io/downloads.html) 0.10.x
-	[Go](https://golang.org/doc/install) 1.8 (to build the provider plugin)

Building The Provider
---------------------

Clone repository to: `$GOPATH/src/github.com/tweag/terraform-provider-nixos`

```sh
$ mkdir -p $GOPATH/src/github.com/tweag; cd $GOPATH/src/github.com/tweag
$ git clone git@github.com:tweag/terraform-provider-nixos
```

Enter the provider directory and build the provider

```sh
$ cd $GOPATH/src/github.com/tweag/terraform-provider-nixos
$ make build
```

Using the provider
----------------------

```hcl
provider "nixos" {
  root = "./nixos-machines/"
}

resource "nixos_node" "my-server" {
  node_name = "my-server-name"
  ip = "10.5.3.1"
  nix = <<NIX
    environment.systemPackages = with pkgs; [
      file
    ];
  NIX
}
```

Developing the Provider
---------------------------

If you wish to work on the provider, you'll first need [Go](http://www.golang.org) installed on your machine (version 1.8+ is *required*). You'll also need to correctly setup a [GOPATH](http://golang.org/doc/code.html#GOPATH), as well as adding `$GOPATH/bin` to your `$PATH`.

To compile the provider, run `make build`. This will build the provider and put the provider binary in the `$GOPATH/bin` directory.

```sh
$ make bin
...
$ $GOPATH/bin/terraform-provider-tweag
...
```

In order to test the provider, you can simply run `make test`.

```sh
$ make test
```

In order to run the full suite of Acceptance tests, run `make testacc`.

*Note:* Acceptance tests create real resources, and often cost money to run.

```sh
$ make testacc
```
