{...}: {
  programs.ghostty = {
    enable = true;
    enableFishIntegration = true;
    # The ghostty systemd service is intended to help ghostty create new
    # windows faster, but in practice it causes me more headaches than the
    # speedup is worth, so I prefer to disable it.
    systemd.enable = false;

    settings = {
      font-family = "Input Mono";
      font-size = 14;

      theme = "naptime OKSolar Dark";

      window-decoration = "none";
      window-padding-color = "extend";
      window-padding-x = 16;
      window-padding-y = 10;
      window-theme = "ghostty";
    };

    themes = {
      "naptime OKSolar Dark" = {
        palette = [
          "0=#093946" # base02
          "1=#f23749" # red
          "2=#819500" # green
          "3=#ac8300" # yellow
          "4=#2b90d8" # blue
          "5=#dd459d" # magenta
          "6=#259d94" # cyan
          "7=#f1e9d2" # base2
          "8=#335e69" # NOT SOLARIZED: in the official solarized this is too dark so everyone changes it
          "9=#d56500" # orange
          "10=#5b7279" # base01
          "11=#657377" # base00
          "12=#98a8a8" # base0
          "13=#7d80d1" # violet
          "14=#8faaab" # base1
          "15=#fbf7ef" # base3
        ];
        background = "#002d38"; # base03
        foreground = "#98a8a8"; # base0
        cursor-color = "#98a8a8"; # base0
        cursor-text = "#093946"; # base02
        selection-background = "#093946"; # base02
        selection-foreground = "#8faaab"; # base1
      };
    };
  };
}
