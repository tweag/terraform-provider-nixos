Terraform Provider NixOS
==================

**Archived**: this project is not maintained anymore. You can use https://github.com/tweag/terraform-nixos instead.

NixOps has too many responsibilities and not a big enough community.
The goal is to reduce NixOps' realm of control by moving all
provisioning steps in to Terraform. This combines NixOp's deep support
for NixOS with Terraform's nearly universal support for hardware and
software providers.

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

This will create a file at `./nixos-machines/my-server.nix`
containing:

```nix
{
  terraform.ip = "10.5.3.1";
  terraform.name = "my-server-name";
  environment.systemPackages = with pkgs; [
    file
  ];
}
```

In your Nix configuration, add a file called `terraform.nix`
containing:

```nix
{ config, lib, pkgs, ... }:
let
  inherit (lib) mkIf mkOption types;
  cfg = config.terraform;
in {
  options = {
    terraform = {
      name = mkOption {
        type = types.string;
      };

      ip = mkOption {
        type = types.string;
      };
    };
  };
}
```

and add it to the `configuration.nix` via:

```nix
{
  imports = [ ./terraform.nix ];
}
```

If you're using the provider with NixOps, you may want to add this to
your `configuration.nix`:

```nix
{
  deployment.targetHost = terraform.ip;
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

## License

Copyright (c) 2018 EURL Tweag.

All rights reserved.

terraform-provider-nixos is free software, and may be redistributed under the terms
specified in the [LICENSE](LICENSE) file.

## About

![Tweag I/O](http://i.imgur.com/0HK8X4y.png)

terraform-provider-nixos is maintained by [Tweag I/O](http://tweag.io/).

Have questions? Need help? Tweet at
[@tweagio](http://twitter.com/tweagio).
