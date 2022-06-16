self: super: {
  mautrix = super.mautrix.overrideAttrs (old: {
    propagatedBuildInputs = old.propagatedBuildInputs ++ [
      super.python3.pkgs.aiosqlite
    ];
  });
  mautrix-signal = super.mautrix-signal.overrideAttrs (old: {
    propagatedBuildInputs = old.propagatedBuildInputs ++ [
      super.python3.pkgs.aiosqlite
    ];
  });
  mautrix-facebook = super.mautrix-facebook.overrideAttrs (old: {
    propagatedBuildInputs = old.propagatedBuildInputs ++ [
      super.python3.pkgs.aiosqlite
    ];
  });
  mautrix-twitter = super.mautrix-twitter.overrideAttrs (old: {
    propagatedBuildInputs = old.propagatedBuildInputs ++ [
      super.python3.pkgs.aiosqlite
    ];
  });
  python3 = super.python3.override {
    packageOverrides = pfinal: pprev: {
      inherit (super.python3.pkgs)
        mautrix
        asyncpg;
      # asyncpg = pprev.asyncpg.overrideAttrs (cur: rec {
      #   version = "0.21.0";
      #   src = channels.latest.python3.pkgs.fetchPypi {
      #     pname = "asyncpg";
      #     inherit version;
      #     sha256 = "U8sqDrMm9h40702i2wHYfOnA6+OW9lopWCnfM04xhj8=";
      #   };
      # });
    };
  };
}
