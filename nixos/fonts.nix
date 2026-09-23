{ pkgs, ... }:

{
  fonts = {
    packages = [
      pkgs.input-fonts
      pkgs.noto-fonts-cjk-sans
      pkgs.noto-fonts-cjk-serif
    ];
  };

  nixpkgs.config.input-fonts.acceptLicense = true;
}
