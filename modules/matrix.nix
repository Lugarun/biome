{ lib, pkgs, config, ... }:

let
  cfg = config.biome.matrix;
  fqdn =
    let
      join = hostName: domain: hostName + lib.optionalString (domain != null) ".${domain}";
    in join config.networking.hostName config.networking.domain;
in {
  options.biome.matrix = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
    };
    address = lib.mkOption {
      type = lib.types.string;
      description = ''
        The address for the server
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    services.postgresql.enable = true;
    services.postgresql.initialScript = pkgs.writeText "synapse-init.sql" ''
      CREATE ROLE "matrix-synapse" WITH LOGIN PASSWORD 'synapse';
      CREATE DATABASE "matrix-synapse" WITH OWNER "matrix-synapse"
        TEMPLATE template0
        LC_COLLATE = "C"
        LC_CTYPE = "C";
    '';

    services.nginx = {
      enable = true;
      recommendedTlsSettings = true;
      recommendedOptimisation = true;
      recommendedGzipSettings = true;
      recommendedProxySettings = true;

      virtualHosts = {
        # This host section can be placed on a different host than the rest,
        # i.e. to delegate from the host being accessible as ${config.networking.domain}
        # to another host actually running the Matrix homeserver.
        #
        "${config.networking.domain}" = {
          enableACME = true;
          forceSSL = true;

          locations."= /.well-known/matrix/server".extraConfig =
            let
              # use 443 instead of the default 8448 port to unite
              # the client-server and server-server port for simplicity
              server = { "m.server" = "${fqdn}:443"; };
            in ''
              add_header Content-Type application/json;
              return 200 '${builtins.toJSON server}';
            '';
          locations."= /.well-known/matrix/client".extraConfig =
            let
              client = {
                "m.homeserver" =  { "base_url" = "https://${fqdn}"; };
                "m.identity_server" =  { "base_url" = "https://vector.im"; };
              };
            # ACAO required to allow element-web on any URL to request this json file
            in ''
              add_header Content-Type application/json;
              add_header Access-Control-Allow-Origin *;
              return 200 '${builtins.toJSON client}';
            '';
          extraConfig =  ''
            location /ws-proxy/ {
              proxy_pass  http://localhost:29331;
              proxy_redirect  http://localhost:29331 https://${config.networking.domain}/ws-proxy;
            }

            # This is the actual websocket endpoint.
            location = /ws-proxy/_matrix/client/unstable/fi.mau.as_sync {
              proxy_pass http://localhost:29331/_matrix/client/unstable/fi.mau.as_sync;
              proxy_set_header Upgrade $http_upgrade;
              proxy_set_header Connection "upgrade";
              proxy_read_timeout 1d;
            }
          '';
        };

        # Reverse proxy for Matrix client-server and server-server communication
        ${fqdn} = {
          enableACME = true;
          forceSSL = true;

          # Or do a redirect instead of the 404, or whatever is appropriate for you.
          # But do not put a Matrix Web client here! See the Element web section below.
          locations."/".extraConfig = ''
            return 404;
          '';

          # forward all Matrix API calls to the synapse Matrix homeserver
          locations."/_matrix" = {
            proxyPass = "http://[::1]:8008"; # without a trailing /
          };
        };
      };
    };
    services.matrix-synapse = {
      enable = true;
      #registration_shared_secret = import ../secrets/matrix-registration-secret.nix;
      settings.server_name = "lutino.space";
      settings.listeners = [
        {
          port = 8008;
          bind_addresses = ["::1"];
          type = "http";
          tls = false;
          x_forwarded = true;
          resources = [
            {
              names = [ "client" "federation" ];
              compress = false;
            }
          ];
        }
      ];
    };
  };
}
