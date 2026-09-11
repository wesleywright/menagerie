{ pkgs, ... }:
{
  home.packages = [
    # Add clipboard functionality for some apps.
    pkgs.wl-clipboard
  ];

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

  # Needed by waybar for getting currently playing status.
  services.playerctld.enable = true;

  wayland.windowManager.sway = {
    enable = true;
    wrapperFeatures.gtk = true;

    config = {
      bars = [
        {
          command = "waybar";
        }
      ];

      floating = {
        criteria = [
          { app_id = "1password"; }
          { app_id = "lollypop"; }
          { app_id = "org.signal.Signal"; }
          { sandbox_app_id = "com.discordapp.Discord"; }
        ];
      };

      gaps = {
        inner = 12;

        smartGaps = "on";
        smartBorders = "on";
      };

      # Runs a wmenu prompt with:
      #  - A font setting of Input Mono Regular, 12pt.
      #  - 8 lines of suggestions.
      #  - The prompt "Launch:".
      #  - Using Solarized color codes:
      #     - Normal and selected background: base03
      #     - Normal and prompt foreground: base2
      #     - Prompt background: base01
      #     - Selected foreground: green
      menu = "${pkgs.wmenu}/bin/wmenu-run -f 'Input Mono Regular 12' -l 8 -p 'Launch:' -N 002b36 -n eee8d5 -M 586e75 -m eee8d5 -S 002b36 -s 859900";

      modifier = "Mod4";

      output = {
        "LG Electronics 27GN950 101NTMXE1251" = {
          adaptive_sync = "on";
          scale = "1.25";
        };
      };

      terminal = "ghostty";

      window = {
        border = 0;
        titlebar = false;
      };
    };
  };
}
