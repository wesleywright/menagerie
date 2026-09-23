{pkgs, ...}: {
  hardware.acpilight.enable = true;
  environment.systemPackages = [
    pkgs.brightnessctl
  ];
}
