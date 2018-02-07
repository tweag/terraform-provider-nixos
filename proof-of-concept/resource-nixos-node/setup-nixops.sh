#!/bin/sh

set -eux

function copy_hwcfg() {
    name=$1
    ip=$2
    root=$3
    nodepath="$3/terraform/.cache/$1/"
    mkdir -p "./$nodepath"
    scp -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null \
        "root@$ip:/etc/nixos/hardware-configuration.nix" "$nodepath"
}

copy_hwcfg "$1" "$2" "$3"
