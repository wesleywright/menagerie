{pkgs, ...}: let
  solarized = import ./solarized.nix;
  barStatusCommand = pkgs.writers.writePython3 "sway-status-command" {} (
    pkgs.replaceVars ./sway-status-command.py {
      criticalColor = "#${solarized.red}";
      systemctl = "${pkgs.systemd}/bin/systemctl";
      playerctl = "${pkgs.playerctl}/bin/playerctl";
    }
  );
in {
  programs.waybar = {
    enable = true;
    settings = {
      mainBar = {
        layer = "top";
        position = "top";
        modules-left = [
          "sway/workspaces"
          "sway/mode"
        ];
        modules-right = [
          "custom/status"
          "privacy"
          "tray"
        ];

        "custom/status" = {
          format = "{}";
          tooltip = false;
          exec = barStatusCommand;
        };

        "tray" = {
          icon-size = 24;
          show-passive-items = true;
          spacing = 8;
        };
      };
    };
    style = pkgs.replaceVars ./waybar.css solarized;
    systemd.enable = true;
  };
}
