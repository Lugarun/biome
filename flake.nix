{
  description = "Biome";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-22.05";
    deploy-rs.url = "github:serokell/deploy-rs";
    home-manager.url = "github:nix-community/home-manager/release-22.05";
    ecosystem = {
      url = "path:/mnt/storage/projects/nix/ecosystem";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    emacs-overlay.url = "github:nix-community/emacs-overlay";
    zotero-remarkable-overlay.url = "github:lugarun/zotero-remarkable";
    nix-matrix-appservices.url = "gitlab:coffeetables/nix-matrix-appservices";
    #photoprism-overlay.url = "github:c0deaddict/photoprism2nix";
    nixpkgs-photoprism.url = "github:newAM/nixpkgs/photoprism";
  };

  outputs = { self
            , nixpkgs
            , deploy-rs
            , home-manager
            , ecosystem
            , emacs-overlay
            , zotero-remarkable-overlay
            , nix-matrix-appservices
            #, photoprism-overlay
            , nixpkgs-photoprism
            , ... }:
  let
    system = "x86_64-linux";
    config = {
      allowUnfree = true;
      #cudaSupport = true; # this causes compilation to take so long as to fail on slower hardware
    };
    overlays = [
      (import ./overlays/davmail.nix)
      (import ./overlays/matrix.nix)
      emacs-overlay.overlay
      zotero-remarkable-overlay.overlay
      nix-matrix-appservices.overlay
      (final: prev: {
        photoprism = nixpkgs-photoprism.legacyPackages.x86_64-linux.photoprism;
      })
      #photoprism-overlay.overlay
    ];
    pkgs = import nixpkgs { inherit system overlays; };
    lib = nixpkgs.lib;
    mkNixosConfiguration = host:
      lib.nixosSystem {
        inherit system;
        modules = [
          ({pkgs, ... }: { nixpkgs = { inherit config overlays; }; })
            nix-matrix-appservices.nixosModule
            "${nixpkgs-photoprism}/nixos/modules/services/web-apps/photoprism.nix"
            #photoprism-overlay.nixosModules.photoprism
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
