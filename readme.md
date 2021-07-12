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

need to setup git encrypt before first commit

# Todo

- setup secrets git-crypt
- fix jasnah wireguard setup, can only get it working via nmcli

# Acknowledge

This setup is heavily inspired by:
- [Andrew Tropn's](https://www.youtube.com/channel/UCuj_loxODrOPxSsXDfJmpng) work [here](https://github.com/abcdw/rde)
- [Christine Dodrill's](https://christine.website/) work [here](https://github.com/Xe/blog-nixos-configs)


ip route add 0.0.0.0/0 via 10.100.0.1 dev wg0
