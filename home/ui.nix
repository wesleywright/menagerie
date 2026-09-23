{pkgs, ...}: {
  gtk = {
    enable = true;
    iconTheme = {
      name = "breeze";
      package = pkgs.kdePackages.breeze-icons;
    };
  };

  home = {
    pointerCursor = {
      enable = true;
      package = pkgs.kdePackages.breeze;
      name = "breeze_cursors";
      size = 24;

      gtk.enable = true;
      sway.enable = true;
    };
  };
}
