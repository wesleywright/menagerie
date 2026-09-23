{pkgs, ...}: let
  solarized = import ./solarized.nix;
in
  with solarized; {
    services = {
      fnott = {
        enable = true;
        package = pkgs.enableDebugging pkgs.fnott;
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
            max-timeout = 60;
            idle-timeout = 60;
          };

          critical = {
            default-timeout = 0;
          };
        };
      };
    };
  }
