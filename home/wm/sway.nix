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
        ];
      };

      bars = [
        {
          inherit fonts;

          position = "top";
          statusCommand = "while date +'%k:%M:%S %Z on %A, %B %-d, %Y'; do sleep 1; done";
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
    wrapperFeatures.gtk = true;
  };
}
