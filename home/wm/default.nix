{ pkgs, ... }:
{
  imports = [
    ./fnott.nix
    ./sway.nix
  ];

  home.packages = [
    # Take screenshots
    pkgs.sway-contrib.grimshot

    # Allows reading and writing to and from the Wayland clipboard using the CLI.
    pkgs.wl-clipboard
  ];

  services = {
    network-manager-applet.enable = true;

    # Needed by waybar for getting currently playing status.
    playerctld.enable = true;

    # Integrates gtklock with `loginctl lock-session` and `systemctl suspend`.
    swayidle = {
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
  };
}
