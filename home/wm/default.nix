{ lib, pkgs, ... }:
let
  # Solarized colors
  # lint:ignore
  base03 = "002b36";
  base02 = "073642";
  base01 = "586e75";
  base00 = "657b83";
  base0 = "839496";
  base1 = "93a1a1";
  base2 = "eee8d5";
  base3 = "fdf6e3";
  yellow = "b58900";
  orange = "cb4b16";
  red = "dc322f";
  magenta = "d33682";
  violet = "6c71c4";
  blue = "268bd2";
  cyan = "2aa198";
  green = "859900";

  modifier = "Mod4";
  workspaces = {
    "1" = "1: default";
    "2" = "2: research";
    "3" = "3: work";
    "4" = "4: games";
    "5" = "5: miscellaneous";
  };
  workspaceBindings = lib.mergeAttrsList (
    lib.mapAttrsToList (name: value: {
      "${modifier}+${name}" = "workspace ${value}";
      "${modifier}+Shift+${name}" = "move container to workspace ${value}";
    }) workspaces
  );
in
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

  wayland.windowManager.sway = {
    enable = true;
    wrapperFeatures.gtk = true;

    config = {
      inherit modifier;

      bars = [
        {
          command = "waybar";
        }
      ];

      colors =
        let
          background = "#${base03}";
          text = "#${base2}";
          makeClass = borderColor: {
            background = background;
            text = text;
            border = borderColor;
            childBorder = borderColor;
            indicator = borderColor;
          };
        in
        {
          background = background;
          focused = makeClass "#${base01}";
          focusedInactive = makeClass "#${base02}";
          unfocused = makeClass "#${base02}";
          placeholder = makeClass "#${base02}";
        };

      defaultWorkspace = "workspace number ${workspaces."1"}";

      floating = {
        criteria = [
          { app_id = "1password"; }
          { app_id = "lollypop"; }
        ];
      };

      gaps = {
        inner = 12;

        smartGaps = "on";
        smartBorders = "on";
      };

      keybindings = lib.mkOptionDefault workspaceBindings;

      # Runs a wmenu prompt with:
      #  - A font setting of Input Mono Regular, 12pt.
      #  - 8 lines of suggestions.
      #  - The prompt "Launch:".
      #  - Using Solarized color codes:
      #     - Normal and selected background: base03
      #     - Normal and prompt foreground: base2
      #     - Prompt background: base01
      #     - Selected foreground: green
      menu = "${pkgs.wmenu}/bin/wmenu-run -f 'Input Mono Regular 12' -l 8 -p 'Launch:' -N ${base03} -n ${base0} -M ${base02} -m ${base1} -S ${green} -s ${base2}";

      output = {
        "LG Electronics 27GN950 101NTMXE1251" = {
          adaptive_sync = "on";
          scale = "1.25";
          bg = "${pkgs.kdePackages.plasma-workspace-wallpapers}/share/wallpapers/Path/contents/images/2560x1600.jpg fill";
        };
      };

      terminal = "ghostty";

      window = {
        border = 2;
        titlebar = false;
      };
    };

    systemd.xdgAutostart = true;
  };
}
