{ lib, pkgs, config, ... }:

let
  cfg = config.biome.wireguard;
in {
  options.biome.wireguard = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };

    networkInfo = lib.mkOption {
      type = lib.types.attrs;
      default = {
        gateway = {
          name = "tanavast";
          endpoint = "104.152.208.10";
          ip_addr = "10.100.0.1";
          pubkey = "aLRsNxmQCXijbaCE5Rsnji+v2MbIqzacX7rFTZhXZHQ=";
        };
        roamers = {
          jasnah = {
            name = "jasnah";
            ip_addr = "10.100.0.2";
            pubkey = "0EJEYou1Nwccz03ETkPUAAqT6It7kbpTisIaCLIOSQE=";
          };
          landline = {
            name = "landline";
            ip_addr = "10.100.0.3";
            pubkey = "nT2H961QvTBK/P/M5t5Ytrj2BLdY7jcq1QNUGBl4ozg=";
          };
          fiasco = {
            name = "fiasco";
            ip_addr = "10.100.0.4";
            pubkey = "msdmphCFSOCBIt9YG2BfKzNluXMygsL+wO6IpQOiEAM=";
          };
        };
      };
    };
  };

  config = let
    makeRoamerPeerConfig = peerInfo: {
      publicKey = peerInfo.pubkey;
      allowedIPs = [ (peerInfo.ip_addr + "/32") ];
    };
    roamerPeers = lib.forEach (lib.attrValues cfg.networkInfo.roamers) makeRoamerPeerConfig;
    gatewayPeers = [ { publicKey = cfg.networkInfo.gateway.pubkey;
                       endpoint = "${cfg.networkInfo.gateway.endpoint}:51820" ;
                       allowedIPs = [ "0.0.0.0/0" ];
                       persistentKeepalive = 3; }];
    isGatewayPeer = cfg.networkInfo.gateway.name == config.networking.hostName;
    isRoamerPeer = lib.elem config.networking.hostName (lib.attrNames cfg.networkInfo.roamers);
  in lib.mkIf (cfg.enable && (isGatewayPeer || isRoamerPeer)) {
    networking.wireguard.interfaces = lib.mkIf isGatewayPeer {
      wg0 = {
        ips = [ (cfg.networkInfo.gateway.ip_addr +"/24") ];
        listenPort = 51820;
        privateKeyFile = "/root/wireguard-keys/private";

        peers = roamerPeers;

        # https://www.ckn.io/blog/2017/11/14/wireguard-vpn-typical-setup/
        postSetup = ''
          ${pkgs.iptables}/bin/iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
          ${pkgs.iptables}/bin/iptables -A FORWARD -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
          ${pkgs.iptables}/bin/iptables -A INPUT -p udp -m udp --dport 51820 -m conntrack --ctstate NEW -j ACCEPT
          ${pkgs.iptables}/bin/iptables -A INPUT -s 10.100.0.0/24 -p tcp -m tcp --dport 53 -m conntrack --ctstate NEW -j ACCEPT
          ${pkgs.iptables}/bin/iptables -A INPUT -s 10.100.0.0/24 -p udp -m udp --dport 53 -m conntrack --ctstate NEW -j ACCEPT
          ${pkgs.iptables}/bin/iptables -A FORWARD -i wg0 -o wg0 -m conntrack --ctstate NEW -j ACCEPT
          ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.100.0.0/24 -o eth0 -j MASQUERADE
        ''; # allow wireguard to route traffic to the internet (turn this into a vpn)

        postShutdown = ''
          ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.100.0.0/24 -o eth0 -j MASQUERADE
        '';
      };
    };

    networking.wg-quick.interfaces = lib.mkIf isRoamerPeer {
      wg0 = {
        address = [ (cfg.networkInfo.roamers.${config.networking.hostName}.ip_addr +"/24") ];
        listenPort = 51820;
        dns = [ cfg.networkInfo.gateway.ip_addr ];
        privateKeyFile = "/root/wireguard-keys/private";
        peers = gatewayPeers;
      };
    };

    services.dnsmasq = let
      mkAddr = attributes: "address=/" + attributes.name + ".biome/" + attributes.ip_addr + "\n";
    in lib.mkIf isGatewayPeer {
      enable = true;
      resolveLocalQueries = true;
      extraConfig = ''
        interface=wg0
        server=1.1.1.1
        '' +
        mkAddr cfg.networkInfo.gateway
        + (lib.concatStrings (lib.forEach (lib.attrValues cfg.networkInfo.roamers) mkAddr));
    };
  };
}
