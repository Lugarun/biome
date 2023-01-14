{
  description = "Biome";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-22.11";
    unstable.url = "nixpkgs/nixos-unstable";
    deploy-rs.url = "github:serokell/deploy-rs";
    flake-utils.url = "github:numtide/flake-utils";
    home-manager.url = "github:nix-community/home-manager/release-22.11";
    nix-gaming = {
      url = "github:fufexan/nix-gaming";
      inputs.unstable.follows = "nixpkgs";
    };
    ecosystem = {
      url = "path:/home/lukas/workspace/nix/ecosystem";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    kmonad.url = "github:kmonad/kmonad?dir=nix";
    kmonad.inputs.nixpkgs.follows = "nixpkgs";
    nix-matrix-appservices.url = "gitlab:coffeetables/nix-matrix-appservices";
    musnix.url = "github:musnix/musnix";
  };

  outputs = inputs @ { self
            , nixpkgs
            , deploy-rs
            , home-manager
            , ecosystem
            , nix-matrix-appservices
            , kmonad
            , nix-gaming
            , unstable
            , musnix
            , flake-utils
            , ... }:
  rec {
    legacyPackages."x86_64-linux" = import nixpkgs {
      system = "x86_64-linux";
      config.allowUnfree = true;
      config.allowAliases = true;
      overlays = [
        (final: prev: { unstable = import unstable { system = final.system; }; })
        (import overlays/davmail.nix)
        (import overlays/matrix.nix)
        (import overlays/rl.nix inputs)
        inputs.kmonad.overlays.default
        inputs.nix-matrix-appservices.overlay
        inputs.nix-gaming.overlays.default
      ];
    };
    devShells."x86_64-linux".default = self.legacyPackages."x86_64-linux".mkShell {
      buildInputs = [
        deploy-rs.packages."x86_64-linux".default
      ];
    };
    nixosConfigurations.jasnah = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        pkgs = legacyPackages."x86_64-linux";
        modules = [
          ./hosts/jasnah/configuration.nix
          musnix.nixosModules.musnix
        ];
    };
    nixosConfigurations.triwizard = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        pkgs = legacyPackages."x86_64-linux";
        modules = [
          ./hosts/triwizard/configuration.nix
        ];
    };
    nixosConfigurations.tanavast = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        pkgs = legacyPackages."x86_64-linux";
        modules = [
          ./hosts/tanavast/configuration.nix
        ];
    };
    nixosConfigurations.fiasco = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        pkgs = legacyPackages."x86_64-linux";
        modules = [
          ./hosts/fiasco/configuration.nix
        ];
    };
    homeConfigurations.lukas = home-manager.lib.homeManagerConfiguration {
      pkgs = legacyPackages."x86_64-linux";
      extraSpecialArgs = { inherit inputs; };
      modules = [
        ecosystem.config
      ];
    };
    deploy.nodes = {
      jasnah = {
        hostname = "jasnah";
        address = "100.87.83.86";
        fastConnection = false;
        autoRollback = true;
        magicRollback = true;
  
        profiles = {
          system = {
            user = "root";
            sshUser = "root";
            path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.jasnah;
          };
          home = {
            user = "lukas";
            profilePath = "/nix/var/nix/profiles/per-user/lukas/home-manager";
            path = deploy-rs.lib.x86_64-linux.activate.custom (self.homeConfigurations.lukas).activationPackage "$PROFILE/activate";
          };
        };
      };
      triwizard = {
        hostname = "triwizard";
        address = "100.99.214.56";
        remoteBuild = true;
        autoRollback = true;
        magicRollback = true;

        profiles = {
          system = {
            user = "root";
            sshUser = "root";
            path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.triwizard;
          };
          home = {
            user = "lukas";
            profilePath = "/nix/var/nix/profiles/per-user/lukas/home-manager";
            path = deploy-rs.lib.x86_64-linux.activate.custom (self.homeConfigurations.lukas).activationPackage "$PROFILE/activate";
          };
        };
      };
      tanavast = {
        hostname = "tanavast";
        address = "100.73.30.58";
        remoteBuild = false;
        autoRollback = true;
        magicRollback = true;

        profiles = {
          system = {
            user = "root";
            sshUser = "root";
            path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.tanavast;
          };
        };
      };
    };
  };
}
