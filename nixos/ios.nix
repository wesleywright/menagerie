{ pkgs, ... }:
{
  # Allows mounting iOS devices.
  services.usbmuxd.enable = true;
  environment.systemPackages = [
    # Enables iOS featuers in certain apps.
    pkgs.libimobiledevice
    # Used for mounting iOS apps as FUSE filesystems.
    pkgs.ifuse
  ];
}
