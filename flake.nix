{
  description = "Biome";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-22.05";
    unstable.url = "nixpkgs/nixos-unstable";
    deploy-rs.url = "github:serokell/deploy-rs";
    home-manager.url = "github:nix-community/home-manager/release-22.05";
    nix-gaming = {
      url = "github:fufexan/nix-gaming";
      inputs.unstable.follows = "nixpkgs";
    };
    ecosystem = {
      url = "path:/home/lukas/workspace/nix/ecosystem";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    emacs-overlay.url = "github:nix-community/emacs-overlay";
    # zotero-remarkable-overlay.url = "github:lugarun/zotero-remarkable";
    kmonad.url = "github:kmonad/kmonad?dir=nix";
    kmonad.inputs.nixpkgs.follows = "nixpkgs";
    nix-matrix-appservices.url = "gitlab:coffeetables/nix-matrix-appservices";
  };

  outputs = { self
            , nixpkgs
            , deploy-rs
            , home-manager
            , ecosystem
            , emacs-overlay
            #, zotero-remarkable-overlay
            , nix-matrix-appservices
            , kmonad
            , nix-gaming
            , unstable
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
      kmonad.overlays.default
      emacs-overlay.overlay
      # zotero-remarkable-overlay.overlay
      nix-matrix-appservices.overlay
      (final: prev: {
        unstable = import unstable {system = final.system; } ;
        nix-gaming = nix-gaming.outputs.packages.x86_64-linux;
        rocket-league = nix-gaming.lib.legendaryBuilder {
          inherit (pkgs) system;
          games = {
            rocket-league = {
              # find names with `legendary list`
              desktopName = "Rocket League";
              # find out on lutris/winedb/protondb
              tricks = ["dxvk" "win10"];
              # google "<game name> logo"
              icon = builtins.fetchurl {
                url = "https://www.pngkey.com/png/full/16-160666_rocket-league-png.png";
                name = "rocket-league.png";
                sha256 = "09n90zvv8i8bk3b620b6qzhj37jsrhmxxf7wqlsgkifs4k2q8qpf";
              };
              # if you don't want winediscordipcbridge running for this game
              discordIntegration = false;
              # if you dont' want to launch the game using gamemode
              gamemodeIntegration = false;
              preCommands = ''
                echo "the game will start!"
              '';
              postCommands = ''
                echo "the game has stopped!"
              '';
            };
          };
          opts = {
            # same options as above can be provided here, and will be applied to all games
            # NOTE: game-specific options take precedence
            wine = nix-gaming.packages.${pkgs.system}.wine-tkg;
          };
        };
      })
      nix-gaming.overlays.default
    ];
    pkgs = import nixpkgs { inherit system overlays; };
    lib = nixpkgs.lib;
    mkNixosConfiguration = host:
      lib.nixosSystem {
        inherit system;
        modules = [
          ({pkgs, ... }: { nixpkgs = { inherit config overlays; }; })
            nix-matrix-appservices.nixosModule
            kmonad.nixosModules.default
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
