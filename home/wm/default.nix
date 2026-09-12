{ pkgs, ... }:
{
  imports = [
    ./sway.nix
    ./waybar.nix
  ];

  home.packages = [
    # Add clipboard functionality for some apps.
    pkgs.wl-clipboard
  ];

  services.network-manager-applet.enable = true;
  # Needed by waybar for getting currently playing status.
  services.playerctld.enable = true;
  # Integrates gtklock with `loginctl lock-session` and `systemctl suspend`.
  services.swayidle = {
    enable = true;
    events =
      let
        lockCommand = "${pkgs.gtklock}/bin/gtklock";
      in
      {
        "before-sleep" = lockCommand;
        "lock" = lockCommand;
      };
  };

}
