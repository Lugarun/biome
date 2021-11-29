{
  description = "Biome";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-21.05";
    deploy-rs.url = "github:serokell/deploy-rs";
    home-manager.url = "github:nix-community/home-manager/release-21.05";
    ecosystem = {
      url = "path:/home/lukas/projects/ecosystem";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, deploy-rs, home-manager, ecosystem, ... }:
  let
    system = "x86_64-linux";
    config = {
      allowUnfree = true;
    };
    pkgs = import nixpkgs { inherit system; };
    lib = nixpkgs.lib;
    mkNixosConfiguration = host:
      lib.nixosSystem {
        inherit system;
        modules = [
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
      tanavast = mkNixosConfiguration "tanavast";
    };
    deploy.nodes = {
      jasnah = mkDeployNode "jasnah" "localhost";
      fiasco = mkDeployNode "fiasco" "192.168.0.16";
      tanavast = mkDeployNode "tanavast" "104.152.208.10";
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
