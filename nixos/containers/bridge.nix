# Network bridge configurations for Tailscale-connected containers.
{
  config,
  lib,
  ...
}: let
  cfg = config.naptime.containerSupport;
in {
  naptime.containerSupport.enable = lib.mkDefault (config.naptime.containers != {});

  networking = lib.mkIf cfg.enable {
    bridges.${cfg.bridgeInterface}.interfaces = [];
    interfaces.${cfg.bridgeInterface}.ipv4.addresses = [
      # TODO: make it easier to specify this via CIDR range?
      {
        address = cfg.bridgeAddress;
        prefixLength = 24;
      }
    ];

    nat = {
      enable = true;
      internalInterfaces = [cfg.bridgeInterface];
      externalInterface = cfg.hostInterface;
    };
  };
}
