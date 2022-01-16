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
    emacs-overlay.url = "github:nix-community/emacs-overlay";
    zotero-remarkable-overlay.url = "github:lugarun/zotero-remarkable";
  };

  outputs = { self, nixpkgs, deploy-rs, home-manager, ecosystem, emacs-overlay, zotero-remarkable-overlay, ... }:
  let
    system = "x86_64-linux";
    config = {
      allowUnfree = true;
    };
    overlays = [
      (import ./overlays/davmail.nix)
      emacs-overlay.overlay
      zotero-remarkable-overlay.overlay
    ];
    pkgs = import nixpkgs { inherit system overlays; };
    lib = nixpkgs.lib;
    mkNixosConfiguration = host:
      lib.nixosSystem {
        inherit system;
        modules = [
          ({pkgs, ... }: { nixpkgs = { inherit config overlays; }; })
          ./hosts/${host}/configuration.nix
        ] ++ (if builtins.elem host ["jasnah" "triwizard"] then [
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
      triwizard = mkNixosConfiguration "triwizard";
    };
    deploy.nodes = {
      jasnah = mkDeployNode "jasnah" "100.87.83.86";
      fiasco = mkDeployNode "fiasco" "100.98.155.47";
      tanavast = mkDeployNode "tanavast" "100.73.30.58";
      triwizard = mkDeployNode "triwizard" "100.110.99.103";
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
