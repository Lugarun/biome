inputs:
  (final: prev: {
    nix-gaming = inputs.nix-gaming.packages.x86_64-linux;
    rocket-league = inputs.nix-gaming.lib.legendaryBuilder {
      system = "x86_64-linux";
      games = {
        rocket-league = {
          # find names with `legendary list`
          desktopName = "Rocket League";
          # find out on lutris/winedb/protondb
          tricks = ["dxvk" "win10"];
          # google "<game name> logo"
          # if you don't want winediscordipcbridge running for this game
          discordIntegration = false;
          # if you dont' want to launch the game using gamemode
          gamemodeIntegration = true;
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
        wine = inputs.nix-gaming.packages."x86_64-linux".wine-tkg;
      };
    };
  })
