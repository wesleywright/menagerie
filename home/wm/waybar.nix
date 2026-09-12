{ ... }:
{
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        modules-left = [
          "sway/workspaces"
          "sway/mode"
          "wlr/taskbar"
        ];
        modules-center = [
          "sway/window"
        ];
        modules-right = [
          "mpris"
          "privacy"
          "tray"
          "clock"
        ];

        "clock" = {
          format = "{:%FT%T%Ez}";
          interval = 1;
          tooltip = false;
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
