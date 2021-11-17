{
  description = "Biome";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-21.05";
    deploy-rs.url = "github:serokell/deploy-rs";
    emanote.url = "https://github.com/srid/emanote/archive/refs/heads/master.tar.gz";
  };

  outputs = { self, nixpkgs, deploy-rs, emanote, ... }:
  let
    system = "x86_64-linux";
    config = {
      allowUnfree = true;
    };
    overlays = [
      (self: super: {
        inherit emanote;
        })
    ];
    pkgs = import nixpkgs { inherit system; };
    lib = nixpkgs.lib;
  in {
    nixosConfigurations.jasnah = lib.nixosSystem {
      inherit system;
      modules = [
        ({ nixpkgs = { inherit config overlays; }; })
        ./hosts/jasnah/configuration.nix
      ];
    };
    deploy.nodes = {
      jasnah = {
        hostname = "localhost";
        fastConnection = true;
        profiles = {
          system = {
            user = "root";
            sshUser = "root";
            path = deploy-rs.lib.${system}.activate.nixos self.nixosConfigurations.jasnah;
          };
        };
      };
    };
    checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    devShell = pkgs.mkShell {
      buildInputs = [
        deploy-rs.packages.${system}
      ];
    };
  };
}
