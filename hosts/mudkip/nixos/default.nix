{ ... }:

{
  imports = [
    ./dpi.nix
    ./filesystems.nix
    ./hardware-configuration.nix
  ];

  # This variable is used to indicate API compatibility, and does not need to be changed on
  # version upgrade.
  system.stateVersion = "24.05"; # Did you read the comment?
}
