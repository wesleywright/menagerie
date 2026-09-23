{ pkgs, ... }:

{
  # Extra utilities for ZSA keyvoards.
  hardware.keyboard.zsa.enable = true;
  environment.systemPackages = [
    pkgs.keymapp
    pkgs.wally-cli
  ];
}
