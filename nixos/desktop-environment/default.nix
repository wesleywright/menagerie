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
      # Since all of my devices use LUKS, secureboot, and an EFI password, it's
      # safe to log in to my user automatically. This makes the boot process
      # more convenient.
      autoLogin = {
        enable = true;
        user = "naptime";
      };

      defaultSession = "sway";

      # Prefer using GDM specifically due to its ability to unlock
      # gnome-keyring with the LUKS password.
      gdm.enable = true;
    };
    xserver.enable = true;
  };
}
