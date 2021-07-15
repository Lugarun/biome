# Steps to add new computer to setup

1. Install nixos on the computer with your ssh key authorized for root
2. Setup wireguard for the computer
  - create new keys using script `build secrets/wireguard/$NAME.pub`
  - add public key to the toml file the wireguard file
  - create computers hosts config file
  - put computers current ip in network.nix file
  - upload secrets using morph
  - deploy new config using morph
  - change computers ip in network.nix to the wireguard ip


# File Setup

On my laptop I want the following downloaded:

- all current projects
- all recent photos

On nextcloud I want access to:

- all photos
- all projects

On fiasco:

```
/Current/Photos
/Current/Projects/haskell
/Current/Projects/school/courses/
/Current/Projects/research/
/Current/Projects/administration/finance
/Current/Projects/administration/school
/Archive/Photos
/Archive/Projects
```

- Everything on nextcloud,
- Current get's synced via syncthing to laptop
- Phone's photos go to current/photos

# Steps

- mount the external hard drive partitions to /mnt/Current and /mnt/Archive
- run `nixos-generate-config` to get the new hardware-configuration.nix file that includes these new mounts
- add the new config to your config system (you should see the new mounts)
- set each folder as an external storage in nextcloud
- setup syncthing to use the same user as next cloud

- new plan: syncthing with filestash because nextcloud is trash (doesn't allow anything except itself to touch it's files, syncing is slow, everything else is bloaty with no fucntionality)
- details: iphone uploads automatically via sftp via photosync or ftpmanager to a syncthing dir, no filestash or nextcloud or anything
- https://blog.mathevet.xyz/posts/syncthing-and-filestash/

# Todo

- setup secrets git-crypt
- clean wireguard setup
- fix dns leak
- setup 
 
# Acknowledgments

This setup is heavily inspired by the following:

- [morph config](https://github.com/Xe/blog-nixos-configs)
- [wireguard setup](https://github.com/abcdw/rde)
- [nixos nextcloud setup](https://jacobneplokh.com/how-to-setup-nextcloud-on-nixos/)
- [syncthing nextcloud integration](https://itcamefromtheinternet.com/blog/nextcloud-syncthing-integration/)
- [syncthing nixos](https://cloud.tissot.de/gitea/benneti/nixos/src/commit/a6ec7bd0206642537596ffdf11049af8312ca6c6)
