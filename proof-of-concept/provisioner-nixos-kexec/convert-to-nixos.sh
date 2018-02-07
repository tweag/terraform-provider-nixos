#!/bin/sh

set -ux

echo "converting $1"

sshopts="-o ServerAliveInterval=1 -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null"

while ! ssh $sshopts "root@$1" true; do
    :
done


ssh $sshopts "root@$1" wget http://195.201.26.107/nixos-system-x86_64-linux.tar.xz

ssh $sshopts "root@$1" /bin/sh -c '"cd /; tar -xf /root/nixos-system-x86_64-linux.tar.xz;"'

ssh $sshopts "root@$1" /bin/sh -c '"cd /; ./kexec_nixos"'

while ! ssh $sshopts "root@$1" true; do
    :
done

cat ./provisioner-nixos-kexec/install-snippet | ssh $sshopts "root@$1" /bin/sh -c '"cat > ./install; chmod +x install; ./install"'

while ! ssh $sshopts "root@$1" true; do
    :
done
