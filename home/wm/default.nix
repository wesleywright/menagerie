{ pkgs, ... }:
let
  solarized = import ./solarized.nix;
in
with solarized;
{
  imports = [
    ./sway.nix
  ];

  home.packages = [
    # Take screenshots
    pkgs.sway-contrib.grimshot

    # Add clipboard functionality for some apps.
    pkgs.wl-clipboard
  ];

  services = {
    fnott = {
      enable = true;
      settings = {
        main = {
          stacking-order = "top-down";

          edge-margin-horizontal = 48;
          edge-margin-vertical = 24;

          notification-margin = 12;

          layer = "overlay";

          background = "${base02}ff";
          border-color = "${base01}ff";

          title-font = "Noto Sans:size=11";
          title-color = "${base0}ff";
          title-format = "%a%A";

          summary-font = "Noto Sans:size=11";
          summary-color = "${base2}ff";
          summary-format = "%s\n";

          body-font = "Noto Sans:size=11";
          body-color = "${base1}ff";
          body-format = "%b";

          progress-bar-height = 16;
          progress-color = "${base1}ff";

          default-timeout = 15;
          idle-timeout = 60;
        };

        critical = {
          default-timeout = 0;
        };
      };
    };

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
