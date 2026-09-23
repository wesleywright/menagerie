{
  config,
  lib,
  pkgs,
  ...
}:

let
  rungame = pkgs.writeShellApplication {
    name = "rungame";
    text = ''
      env LD_PRELOAD="" \
        ${pkgs.gamemode}/bin/gamemoderun \
        ${pkgs.gamescope}/bin/gamescope \
          --adaptive-sync \
          --fullscreen \
          --rt \
          --max-scale 1 \
          --expose-wayland \
        "$@"
    '';
  };
in
{
  config = lib.mkIf config.naptime.gaming.enable {
    # This seems to help with fully recognizing DualSense controllers.
    hardware.uinput.enable = true;

    programs = {
      # Gamemode allows games to enable OS performance optimizations dynamically, which can have a major boost for some games
      gamemode.enable = true;

      steam = {
        enable = true;
        extraCompatPackages = [ pkgs.proton-ge-bin ];
        extraPackages = [ rungame ];
      };
    };

    # Setting CPU governor settings only works when the user is in this group
    users.users.naptime.extraGroups = [ "gamemode" ];
  };
}
