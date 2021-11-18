{
  description = "Biome";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-21.05";
    deploy-rs.url = "github:serokell/deploy-rs";
    emanote.url = "https://github.com/srid/emanote/archive/refs/heads/master.tar.gz";
    home-manager.url = "github:nix-community/home-manager";
    ecosystem = {
      url = "path:/home/lukas/projects/ecosystem";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, deploy-rs, emanote, home-manager, ecosystem, ... }:
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
    mkNixosConfiguration = host:
      lib.nixosSystem {
        inherit system;
        modules = [
          ({ nixpkgs = { inherit config overlays; }; })
          ./hosts/${host}/configuration.nix
        ] ++ (if host == "jasnah" then [
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.lukas = ecosystem.config;
          } ] else []);
      };
    mkDeployNode = host: opshost:
    {
      hostname = opshost;
      fastConnection = true;
      profiles = {
        system = {
          user = "root";
          sshUser = "root";
          path = deploy-rs.lib.${system}.activate.nixos self.nixosConfigurations.${host};
        };
      };
    };
  in {
    nixosConfigurations = {
      jasnah = mkNixosConfiguration "jasnah";
      fiasco = mkNixosConfiguration "fiasco";
    };
    deploy.nodes = {
      jasnah = mkDeployNode "jasnah" "localhost";
      fiasco = mkDeployNode "fiasco" "192.168.0.16";
    };
    checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
    devShell.${system} = pkgs.mkShell {
      buildInputs = [
        deploy-rs.defaultPackage.${system}
        pkgs.morph
      ];
    };
  };
}
