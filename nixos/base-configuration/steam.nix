{ pkgs, ... }:

{
  environment.systemPackages = [
    # Make gamescope for available for games that need it.
    pkgs.gamescope
  ];

  # This seems to help with fully recognizing DualSense controllers.
  hardware.uinput.enable = true;

  programs = {
    # Gamemode allows games to enable OS performance optimizations dynamically, which can have a major boost for some games
    gamemode.enable = true;

    steam = {
      enable = true;
      extraCompatPackages = [ pkgs.proton-ge-bin ];
    };
  };

  # Setting CPU governor settings only works when the user is in this group
  users.users.naptime.extraGroups = [ "gamemode" ];
}
