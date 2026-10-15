{pkgs, ...}: {
  fonts = {
    packages = [
      pkgs.input-fonts
      pkgs.maple-mono.variable
      pkgs.noto-fonts-cjk-sans
      pkgs.noto-fonts-cjk-serif
    ];
  };

  nixpkgs.config.input-fonts.acceptLicense = true;
}
