{
  config,
  lib,
  ...
}: let
  cfg = config.naptime.gaming;
in {
  config = lib.mkIf cfg.enable {
    programs.mangohud = {
      enable = true;
      settings = {
        # Default to not displaying the HUD
        preset = 0;
      };
    };
  };
}
