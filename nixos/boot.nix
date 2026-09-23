{
  lib,
  inputs,
  pkgs,
  ...
}:

{
  imports = [
    inputs.lanzaboote.nixosModules.lanzaboote
  ];

  boot.kernelPackages = pkgs.linuxPackages_latest;

  boot.lanzaboote = {
    enable = true;
    pkiBundle = "/var/lib/sbctl";
  };

  boot.loader.efi.canTouchEfiVariables = true;
  # Disable in favor of lanzaboote.
  boot.loader.systemd-boot.enable = lib.mkForce false;

  environment.systemPackages = [
    # Useful for debugging Secure Boot status.
    pkgs.sbctl
  ];
}
