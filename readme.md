# Biome

Welcome to Biome, my vpn/selfhosting setup!
Here are the features we have so far:
- everything runs nixos so we have one click deploys and updates to all devices on the net
- wireguard (laptop `jasnah`, phone, local server `fiasco`, remote server `tanavast`)
- dnsmasq (each device and service gets a `.biome` domain)
- syncthing (laptop `jasnah` syncs with file server on my lan `fiasco`)
- restic (my file server `fiasco` makes encrypted backups to a onedrive account)

## Wireguard

Right now every device connects to one central node. I had tried to setup a mesh network however most of my devices
have dynamic ip's so a single central node is easier to setup.

### Steps to add new computer to wireguard

1. Install nixos on the computer with your ssh key authorized for root access
2. Setup wireguard for the computer
  - create new keys using script `make secrets/wireguard/$NAME.pub`
  - add public key to the json wireguard config file
  - create computers config under `/hosts`
  - put computers deploy info in `/ops/network.nix`
  - run `make morph-overhaul`

## File Setup

I love syncthing but it doesn't play nice with ios. To bridge this gap I tried nextcloud, however the nextcloud
external local folder feature is horrible. This means nextcloud won't play nice with syncthing.

I am currently looking into using sftp to sync photos from my iphone to
my other devices and using something like [filestash](https://www.filestash.app/) or [gossa](https://github.com/pldubouilh/gossa) or [h5ai](https://larsjung.de/h5ai/) for file web access.
I also want to setup a nice photo service like [lychee](https://lychee.electerious.com/).

### Restic Campus Onedrive

This is my current backup solution. My school gives it's students free access
to 5 TB of onedrive storage. I am using this space as a restic repository
to backup my files. Three times a week all of my files on `fiasco` (my file server) are backed
up to the restic server. Here are the initial setup steps.


Setup rclone with onedrive giving the repo a name that matches the later restic config.
```
rclone config
```
Then find the rclone config and add it to your secrets.
```
rclone config file
```
Finally create a password for your restic backup and add it to your secrets. To manually trigger a backup run
```
systemctl start restic-backups-uwonedrive.service
```

## Todo

- fix mount from nextcloud to syncthing (move things appropriately) on fiasco
- fix dns leak
- iphone file sync
- web file frontend
- add personal website hosting
- add calendar 
 
## Acknowledgments

This setup is heavily inspired by the following:

- [morph config](https://github.com/Xe/blog-nixos-configs)
- [wireguard setup](https://github.com/abcdw/rde)
- [syncthing nixos](https://cloud.tissot.de/gitea/benneti/nixos/src/commit/a6ec7bd0206642537596ffdf11049af8312ca6c6)
- [nixos restic rclone](https://francis.begyn.be/blog/nixos-restic-backups) [and this](https://wiki.cont.run/self-hosted-services/)
- [selfhosted software listing](https://github.com/awesome-selfhosted/awesome-selfhosted)
