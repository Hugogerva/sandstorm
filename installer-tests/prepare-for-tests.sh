#!/bin/bash
set -euo pipefail

# This script exists to find out if you have vagrant and libvirt set
# up, and to help you do first-time setup tasks so you can run the
# installer tests.

# These two functions are borrowed from install.sh.

error() {
  if [ $# != 0 ]; then
    echo -en '\e[0;31m' >&2
    echo "$@" | (fold -s || cat) >&2
    echo -en '\e[0m' >&2
  fi
}

fail() {
  error "$@"
  exit 1
}

# Look for executable dependencies.
for dep in vagrant ; do
    which $dep > /dev/null || fail "Please install $dep(1)."
done

# Check if Vagrant has the mutate plugin; if not, we install it, since
# we use it during this script to convert a few Vagrant base boxes
# into libvirt format.
(vagrant plugin list | grep -q mutate) || vagrant plugin install vagrant-mutate

# Download this particular random Debian Jessie VM and then convert it to
# libvirt format.
(vagrant box list | grep -q thoughtbot_jessie) || vagrant box add thoughtbot_jessie https://vagrantcloud.com/thoughtbot/boxes/debian-jessie-64/versions/0.1.0/providers/virtualbox.box
(vagrant box list | grep -q 'thoughtbot_jessie.*libvirt') || vagrant mutate thoughtbot_jessie libvirt

# Do the same for the main Trusty (Ubuntu 14.04) VM.
(vagrant box list | grep -q 'trusty64') || vagrant box add trusty64 https://cloud-images.ubuntu.com/vagrant/trusty/current/trusty-server-cloudimg-amd64-vagrant-disk1.box
(vagrant box list | grep -q 'trusty64.*libvirt') || vagrant mutate trusty64 libvirt
