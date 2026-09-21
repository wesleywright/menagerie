{ lib, pkgs, ... }:
let
  solarized = import ./solarized.nix;

  modifier = "Mod4";
  workspaces = {
    "1" = "1/default";
    "2" = "2/research";
    "3" = "3/work";
    "4" = "4/games";
    "5" = "5/miscellaneous";
  };
  workspaceBindings = lib.mergeAttrsList (
    lib.mapAttrsToList (name: value: {
      "${modifier}+${name}" = "workspace ${value}";
      "${modifier}+Shift+${name}" = "move container to workspace ${value}";
    }) workspaces
  );

  fonts = {
    names = [ "Input Mono" ];
    size = 12.0;
  };

  # Runs a wmenu command (either wmenu or wmenu-run) with common styling options.
  wmenuCommand =
    program:
    with solarized;
    "${pkgs.wmenu}/bin/${program} -f 'Input Mono Regular 12' -N ${base03} -n ${base0} -M ${base02} -m ${base1} -S ${green} -s ${base2} -i";
  wmenu = wmenuCommand "wmenu";
  wmenu-run = wmenuCommand "wmenu-run";

  powerMenu = pkgs.writeShellScript "power-menu" ''
    CHOICE=$(
      echo -e 'Suspend\nLog out\nReboot\nShutdown\n' |
      ${wmenu} -p 'Run which power command?' -l 4
    )

    function confirm {
      ANSWER=$(echo -e "No\nYes\n" | ${wmenu} -p "Are you sure you want to $1?" -l 2)
      [[ $ANSWER =~ ^Yes$ ]]
    }

    case "$CHOICE" in
      *Suspend) systemctl suspend ;;
      *"Log out") confirm "log out" && swaymsg exit ;;
      *Reboot) confirm "reboot" && systemctl reboot ;;
      *Poweroff) confirm "shutdown" && systemctl poweroff ;;
    esac
  '';

  barStatusCommand = pkgs.writers.writePython3 "sway-status-command" { } (
    builtins.readFile ./sway-status-command.py
  );
in
with solarized;
{
  wayland.windowManager.sway = {
    enable = true;

    config = {
      inherit fonts;
      inherit modifier;

      assigns = {
        ${workspaces."1"} = [
          { sandbox_app_id = "com.discordapp.Discord"; }
          { app_id = "org.signal.Signal"; }
        ];
        ${workspaces."4"} = [
          { class = "steam"; }
          { class = "steam_app.*"; }
        ];
      };

      bars = [
        {
          inherit fonts;

          position = "top";
          statusCommand = "${barStatusCommand}";
          trayPadding = 8;

          extraConfig = ''
            height 32
          '';

          colors =
            let
              workspaceColors = text: {
                background = "#${base03}";
                border = "#${base03}";
                text = "#${text}";
              };
            in
            {
              background = "#${base03}";
              separator = "#${base0}";
              statusline = "#${base0}";
              focusedStatusline = "#${base1}";

              focusedWorkspace = workspaceColors green;
              activeWorkspace = workspaceColors base2;
              inactiveWorkspace = workspaceColors base1;
              urgentWorkspace = workspaceColors orange;
            };
        }
      ];

      colors =
        let
          makeClass = foreground: background: {
            background = background;
            text = foreground;
            border = background;
            childBorder = background;
            indicator = background;
          };
          inactive = makeClass "#${base1}" "#${base02}";
        in
        {
          background = "#${base03}";
          focused = makeClass "#${base2}" "#${base01}";
          focusedInactive = inactive;
          placeholder = inactive;
          unfocused = inactive;
          urgent = makeClass "#${base1}" "#${orange}";
        };

      defaultWorkspace = "workspace ${workspaces."1"}";

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

      input = {
        # Use caps as escape on caterpie's built-in keyboard.
        "1:1:AT_Translated_Set_2_keyboard" = {
          xkb_options = "caps:escape";
        };

        "type:touchpad" = {
          # "Clickfinger" settings allow you to use one/two/three
          # fingers to do a left/right/middle click, repsectively.
          click_method = "clickfinger";
          clickfinger_button_map = "lrm";

          # Enables tap-to-click, using the same finger mapping as above.
          tap = "enabled";
          tap_button_map = "lrm";
        };
      };

      keybindings =
        let
          brightness = "${pkgs.brightnessctl}/bin/brightnessctl --class backlight --exponent=3 --min-value=8000 set";
          pamixer = "${pkgs.pamixer}/bin/pamixer";
          playerctl = "${pkgs.playerctl}/bin/playerctl";
        in
        lib.mkOptionDefault (
          workspaceBindings
          // {
            "${modifier}+l" = "exec loginctl lock-session";
            "${modifier}+p" = "exec ${powerMenu}";

            "XF86AudioLowerVolume" = "exec ${pamixer} --decrease 1";
            "XF86AudioMute" = "exec ${pamixer} --toggle-mute";
            "XF86AudioRaiseVolume" = "exec ${pamixer} --increase 1";

            "XF86AudioPlay" = "exec ${playerctl} play-pause";
            "XF86AudioNext" = "exec ${playerctl} next";
            "XF86AudioPrev" = "exec ${playerctl} previous";

            "XF86MonBrightnessDown" = "exec ${brightness} 3.25%-";
            "XF86MonBrightnessUp" = "exec ${brightness} +3.25%";
          }
        );

      # Runs a wmenu prompt with:
      #  - A font setting of Input Mono Regular, 12pt.
      #  - 8 lines of suggestions.
      #  - The prompt "Launch:".
      #  - Using Solarized color codes:
      #     - Normal and selected background: base03
      #     - Normal and prompt foreground: base2
      #     - Prompt background: base01
      #     - Selected foreground: green
      menu = "${wmenu-run} -p 'Launch:' -l 8";

      output =
        let
          background = "${pkgs.kdePackages.plasma-workspace-wallpapers}/share/wallpapers/Path/contents/images/2560x1600.jpg fill";
          caterpieDisplay = {
            inherit background;
            adaptive_sync = "on";
            allow_tearing = "yes";
            scale = "1.6";
          };
        in
        {
          "LG Electronics 27GN950 101NTMXE1251" = {
            inherit background;
            adaptive_sync = "on";
            allow_tearing = "yes";
            scale = "1.25";
          };

          # For some reason, sway and swaybg see different names for the built-in Framework display
          "BOE NE135A1M-NY1" = caterpieDisplay;
          "BOE NE135A1M-NY1 Unknown" = caterpieDisplay;
        };

      terminal = "ghostty";

      window = {
        border = 2;
        titlebar = false;
      };
    };

    systemd.xdgAutostart = true;
    wrapperFeatures.gtk = true;
  };
}
