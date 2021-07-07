{ config, pkgs, ... }:
{
  imports =
    [ 
      ./hardware-configuration.nix
      ../../common
    ];

  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.device = "/dev/xvda";
  boot.initrd.checkJournalingFS = false;

  networking.hostName = "tanavast"; # Define your hostname.
  time.timeZone = "America/Toronto";

  networking.useDHCP = false;
  networking.interfaces.eth0.useDHCP = false;


  networking.interfaces.eth0.ipv4.addresses = [ {
    address = "104.152.208.10";
    prefixLength = 24;
  } ];
  networking.defaultGateway = "104.152.208.1";
  networking.nameservers = ["8.8.8.8"];

  networking.nat.enable = true;
  networking.nat.externalInterface = "eth0";
  networking.nat.internalInterfaces = [ "wg0" ];
  networking.firewall = {
    allowedUDPPorts = [ 51820 ];
  }; # Open wireguard port in the firewall

  networking.wireguard.interfaces = {
    wg0 = {
      ips = [ "10.100.0.1/24" ];
      listenPort  = 51820;
      postSetup = ''
        ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.100.0.0/24 -o eth0 -j MASQUERADE
      ''; # allow wireguard to route traffic to the internet (turn this into a vpn)

      postShutdown = ''
        ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.100.0.0/24 -o eth0 -j MASQUERADE
      '';
      privateKeyFile = "/root/wireguard-keys/private";
      peers = [
        {
          # laptop
          publicKey = "rVN0RlOP/KX8I9i0lrF4v6YUEdyn3kd5g6LQP+8BCX0=";
          allowedIPs = [ "10.100.0.2/32" ];
        }
      ];
    };
  };

  system.stateVersion = "21.05";
}

