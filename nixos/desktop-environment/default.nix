{ pkgs, ... }:

{
  programs.gtklock = {
    enable = true;
    config = {
      main = {
        background = "${pkgs.kdePackages.plasma-workspace-wallpapers}/share/wallpapers/Path/contents/images/2560x1600.jpg";
        date-format = "%T";
        time-format = "%F";
      };
    };
    modules = [
      pkgs.gtklock-powerbar-module
    ];
    style = builtins.readFile ./gtklock.css;
  };
  programs.sway = {
    enable = true;
    extraPackages = [ ];
  };

  services.displayManager.sddm.enable = true;
  services.xserver.enable = true;
}
