{
  pkgs,
  system,
  ...
}: {
  home.packages = [
    pkgs.libreoffice
    pkgs.zoom-us
  ];
}
