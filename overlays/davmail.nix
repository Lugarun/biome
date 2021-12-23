self: super: {
  davmail = super.davmail.overrideAttrs (old: rec {
    version = "6.0.1";
    pname = "davmail";
    url = "https://sourceforge.net/projects/${pname}/files/${pname}/${version}/${pname}-${version}-3390.zip";
    sha256 = "sha256-QK0G4p5QQPou67whuvzGHOgH21PL0Rb9PY8x+toMP8Q=";
  });
}
