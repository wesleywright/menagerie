{ config, ... }:

{
  programs.firefox = {
    # New default as of 26.05; set explicitly to silence warnings
    configPath = "${config.xdg.configHome}/mozilla/firefox";

    enable = true;
  };
}
