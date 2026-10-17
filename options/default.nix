{lib, ...}: {
  imports = [
    ./containers.nix
    ./services.nix
  ];

  options.naptime = {
    gaming.enable = lib.options.mkEnableOption "gaming support";
  };
}
