# Wireguard

Right now every device connects to one central node. I had tried to setup a mesh network however most of my devices
have dynamic ip's so a single central node is easier to setup.

## Steps to add new computer to wireguard

1. Install nixos on the computer with your ssh key authorized for root access
2. Setup wireguard for the computer
  - create new keys using script `make secrets/wireguard/$NAME.pub`
  - add public key to the json wireguard config file
  - create computers config under `/hosts`
  - put computers deploy info in `/ops/network.nix`
  - run `make morph-overhaul`

# File Setup

I love syncthing but it doesn't play nice with ios. To bridge this gap I tried nextcloud, however the nextcloud
external local folder feature is horrible. This means nextcloud won't play nice with syncthing.

I am currently looking into using sftp to sync photos from my iphone to
my other devices and using something like [filestash](https://www.filestash.app/) for file web access.
I also want to setup a nice photo service like [lychee](https://lychee.electerious.com/).

I also need to setup backups, I plan on using [restic](https://restic.net/).

# Todo

- fix dns leak
- iphone file sync
- 
 
# Acknowledgments

This setup is heavily inspired by the following:

- [morph config](https://github.com/Xe/blog-nixos-configs)
- [wireguard setup](https://github.com/abcdw/rde)
- [syncthing nixos](https://cloud.tissot.de/gitea/benneti/nixos/src/commit/a6ec7bd0206642537596ffdf11049af8312ca6c6)
