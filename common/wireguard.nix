{ lib, pkgs, config, ... }:
let
  metadata = lib.importJSON ../config/wireguard.json;

  toList = set: (map (key: builtins.getAttr key set) (builtins.attrNames set));

  roamPeer = hostdata:
  {
    publicKey = hostdata.pubkey;
    allowedIPs = [ (hostdata.ip_addr + "/32") ];
  };

  serverPeer = hostdata:
  {
    publicKey = hostdata.pubkey;
    allowedIPs = [ (hostdata.ip_addr + "/32") ];
    persistentKeepalive = 25;
    endpoint = "${hostdata.endpoint}:51820";
  };

  gatewayPeer = hostdata:
  {
    publicKey = hostdata.pubkey;
    allowedIPs = [ "0.0.0.0/0" ];
    persistentKeepalive = 3;
    endpoint = "${hostdata.endpoint}:51820";
  };

  createPeer = hostdata: if hostdata.peerType == "roam"
                         then roamPeer hostdata
                         else if hostdata.peerType == "server"
                              then serverPeer hostdata
                              else gatewayPeer hostdata;

  baseInterface = hostdata:
  {
    ips = [ (hostdata.ip_addr +"/24") ];
    listenPort = 51820;
    privateKeyFile = "/root/wireguard-keys/private";
    peers = [ (createPeer metadata.tanavast) ];
  };

  gatewayInterface = hostdata:
  {
    inherit (baseInterface hostdata) ips listenPort privateKeyFile;
    # https://www.ckn.io/blog/2017/11/14/wireguard-vpn-typical-setup/
    peers = builtins.map createPeer (toList (builtins.removeAttrs metadata [ hostdata.name ]));
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
  createInterface = hostname: if metadata."${hostname}".peerType == "gateway"
                              then gatewayInterface metadata."${hostname}"
                              else baseInterface metadata."${hostname}";

  createQuickInterface = hostname:
  let hostdata = metadata."${hostname}";
  in
  {
    address = [ (hostdata.ip_addr +"/24") ];
    listenPort = 51820;
    dns = [ metadata.tanavast.ip_addr ];
    privateKeyFile = "/root/wireguard-keys/private";
    peers = [ (createPeer metadata.tanavast) ];
  };

  hostname = config.networking.hostName;

in
{
  networking.wireguard.interfaces = if metadata."${hostname}".peerType == "roam"
                                    then {}
                                    else { wg0 = createInterface config.networking.hostName; };

  networking.wg-quick.interfaces = if metadata."${hostname}".peerType == "roam"
                                   then { wg0 = createQuickInterface config.networking.hostName; }
                                   else {};

  services = if metadata."${hostname}".peerType == "gateway"
             then {
               dnsmasq = {
                 enable = true;
                 resolveLocalQueries = true;
                 extraConfig = ''
                   interface=wg0
                   server=1.1.1.1
                   address=/tanavast.home/10.100.0.1
                   address=/jasnah.home/10.100.0.2
                   address=/landline.home/10.100.0.3
                   address=/fiasco.home/10.100.0.4
                   address=/nextcloud.home/10.100.0.4
                 '';
               };
             }
             else {};
}
