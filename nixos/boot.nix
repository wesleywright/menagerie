{
  lib,
  inputs,
  pkgs,
  ...
}: {
  imports = [
    inputs.lanzaboote.nixosModules.lanzaboote
  ];

  boot = {
    # Reduce boot verbosity outside of Plymouth.
    consoleLogLevel = 3;

    # Explicitly use the latest available kernel. This has helped me avoid
    # odd GPU issues in the past.
    kernelPackages = pkgs.linuxPackages_latest;

    # Reduce boot verbosity outside of Plymouth.
    kernelParams = [
      "quiet"
      "rd.udev.log_level=3"
      "rd.systemd.show_status=auto"
    ];

    # Lanzaboote signs the contents of the /boot partition for use with SecureBoot.
    lanzaboote = {
      enable = true;
      pkiBundle = "/var/lib/sbctl";
    };

    loader.efi.canTouchEfiVariables = true;
    # Disable in favor of lanzaboote.
    loader.systemd-boot.enable = lib.mkForce false;

    # Like other settings, reduce boot verbosity outside of Plytmouth.
    initrd.verbose = false;

    # Enable a pretty boot screen instead of flickering console text.
    plymouth.enable = true;
  };

  environment.systemPackages = [
    # Useful for debugging Secure Boot status.
    pkgs.sbctl
  ];
}
