{ ... }:

{
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

      theme = "iTerm2 Solarized Dark";

      window-decoration = "none";
      window-padding-color = "extend";
      window-padding-x = 16;
      window-padding-y = 10;
      window-theme = "ghostty";
    };
  };
}
