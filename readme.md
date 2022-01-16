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
  
### Installation steps

#### Install nixos on the computer

#### Authorize Root SSH Access
Copy this line to the nixos config.
```
users.users.root.openssh.authorizedKeys.keys = authorizedSSHKeys;
```
#### Add to tailscale
You will need to access the computer in order to deploy a new nixos instance to it.
If the computer isn't accessible you can add it to Tailscale by adding the `modules/tailscale.nix`
code to the nix config and then running `tailscale up` to validate the machine.

#### Create the basic config for the machine
Copy the configuration generated during the nixos install from the machine to the `hosts` file and
adjust it to your needs.

You will need to add the computer to:
1. `/ops/network.nix`
2. `/flake.nix`

#### Install the new nixos configuration
Now you can run `make deploy-rs/computer` to deploy your configuration where computer is your new computer name.

#### Additional Steps
If you included home manager you will also need to:

##### Install Doom

```
git clone --depth 1 https://github.com/hlissner/doom-emacs ~/.emacs.d
~/.emacs.d/bin/doom install
```

##### Activate Remarkable for sync
```
rmapi
```


##### Setup syncthing

First add the computer to `syncthing.json` with a random id.
Then deploy to the computer, once it is running get the actual id from `localhost:8384` and put it in `syncthing.json`.
Then open the syncthing web interface on all computers trying to connect to each other and accept the notifications.
Then wait 2-3 years for the files to sync the first time

##### TODO Download Password Manager

##### Install Steam Games

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

#### Accessing your backups

Make sure rclone can see the backups.
```
rclone --config secrets/restic/uwonedrive-rclone-config lsd uwonedrive:backups
```

Make sure rclone config is in the right place.
```
rclone config file
```

List snapshots

```
restic -r rclone:uwonedrive:backups snapshots
```

Recover snapshots
```
restic -r rclone:uwonedrive:backupsrestore df2564be --target /tmp/restore-work
```

## Todo

- secret distribution (uses legacy morph right now)
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
- [flake and deploy-rs showcase](https://github.com/bbigras/nix-config/blob/master/nix/mk-host.nix)
