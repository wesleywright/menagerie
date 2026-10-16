{pkgs, ...}: {
  programs = {
    gtklock = {
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

    sway = {
      enable = true;
      extraPackages = [];
    };
  };

  services = {
    displayManager = {
      autoLogin = {
        enable = true;
        user = "naptime";
      };
      defaultSession = "sway";
      gdm.enable = true;
    };
    xserver.enable = true;
  };
}
