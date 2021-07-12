{ lib, pkgs, ... }:
let
  metadata = lib.importJSON ../config/wireguard.json;

  toList = set: (map (key: builtins.getAttr key set) (builtins.attrNames set));

  roamPeer = hostdata:
  {
    publicKey = hostdata.pubkey;
    allowedIPs = [ hostdata.ip_addr ];
  };

  serverPeer = hostdata:
  {
    publicKey = hostdata.pubkey;
    allowedIPs = [ hostdata.ip_addr ];
    persistentKeepalive = 25;
    endpoint = "${hostdata.endpoint}:51820";
  };

  gatewayPeer = hostdata:
  {
    publicKey = hostdata.pubkey;
    allowedIPs = [ "0.0.0.0/0" ];
    persistentKeepalive = 25;
    endpoint = "${hostdata.endpoint}:51820";
  };

  createPeer = hostdata: if hostdata.peerType == "roam"
                         then roamPeer hostdata
                         else if hostdata.peerType == "server"
                              then serverPeer hostdata
                              else gatewayPeer hostdata;

  baseInterface = hostdata:
  {
    ips = [ "${hostdata.ip_addr}/24" ];
    listenPort = 51820;
    privateKeyFile = "/root/wireguard-keys/private";
    peers = builtins.map createPeer (toList (builtins.removeAttrs metadata [ hostdata.name ]));
  };

  gatewayInterface = hostdata:
  {
    inherit (baseInterface hostdata) ips listenPort privateKeyFile peers;
    postSetup = ''
      ${pkgs.iptables}/bin/iptables -t nat -A POSTROUTING -s 10.100.0.0/24 -o eth0 -j MASQUERADE
    ''; # allow wireguard to route traffic to the internet (turn this into a vpn)

    postShutdown = ''
      ${pkgs.iptables}/bin/iptables -t nat -D POSTROUTING -s 10.100.0.0/24 -o eth0 -j MASQUERADE
    '';

  };

  createInterface = hostname: if metadata."${hostname}".peerType == "gateway"
                              then gatewayInterface metadata."${hostname}"
                              else baseInterface metadata."${hostname}";
in
rec {
  inherit createInterface;
}
