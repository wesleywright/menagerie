{ pkgs, ... }:
let
  confirm-command =
    command: prompt:
    pkgs.writeShellScript "confirm-command" ''
      ${pkgs.zenity}/bin/zenity --question --text "${prompt}" --default-cancel && ${command}
    '';
in
{
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        modules-left = [
          "custom/power"
          "sway/workspaces"
          "sway/mode"
        ];
        modules-center = [
          "sway/window"
        ];
        modules-right = [
          "mpris"
          "privacy"
          "tray"
          "custom/clock"
        ];

        "custom/clock" = {
          format = "{}";
          interval = 1;
          tooltip = false;
          exec = pkgs.writeShellScript "get-current-time-for-waybar" "date '+%k:%M:%S %Z on %A, %B %-d, %Y'";
        };

        "custom/power" = {
          format = "⏻";
          tooltip = false;
          menu = "on-click";
          menu-file = ./waybar-power-menu.xml;
          menu-actions = {
            "suspend" = "systemctl suspend";
            "logout" = confirm-command "${pkgs.sway}/bin/swaymsg exit" "Are you sure you want to log out?";
            "reboot" =
              confirm-command "${pkgs.systemd}/bin/systemctl reboot" "Are you sure you want to reboot?";
            "shutdown" =
              confirm-command "${pkgs.systemd}/bin/systemctl poweroff" "Are you sure you want to shut down?";
          };
        };

        "mpris" = {
          format = "{player_icon}{dynamic}{status_icon}";
          interval = 1;
          prefer-album-artist = true;
        };

        "tray" = {
          show-passive-items = true;
          spacing = 10;
        };
      };
    };
    style = ./waybar.css;
  };
}
