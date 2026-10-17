# Options related to Tailscale-connected service containers.
{
  config,
  lib,
  ...
}: let
  cfg = config.naptime;
in {
  options.naptime = {
    # Various settings that are used in common across containers.
    containerSupport = {
      enable = lib.options.mkEnableOption "support for Tailscale service containers";

      bridgeInterface = lib.mkOption {
        default = "br-container";
        description = lib.mdDoc ''
          Name of bridge interface to use for naptime containers.

          Each container will route traffic through this interface. The host
          system will perform NAT for traffic coming from this bridge.
        '';
        type = lib.types.str;
      };
      bridgeAddress = lib.mkOption {
        # TODO: make it easier to specify this + CIDR + automatically pick
        # addressses for containers
        default = "10.0.0.1";
        description = "IPv4 address to use for the container bridge.";
        type = lib.types.str;
      };

      configDirectory = lib.mkOption {
        default = "/etc/naptime/containers/";
        description = lib.mdDoc ''
          Directory where per-container configuration files are stored.

          By default, each container declared via `naptime.containers.<name>`
          will receive its own configuration subdirectory with the name
          `<name>`. This subdirectory will be automaticallly mounted into the
          container under `/mnt/config`.
        '';
        type = lib.types.path;
      };

      hostInterface = lib.mkOption {
        description = lib.mdDoc ''
          Host network interface to route container traffic through.

          This interface will receive traffic from the bridge interface via
          NAT.
        '';
        type = lib.types.str;
      };

      stateDirectory = lib.mkOption {
        default = "/var/lib/naptime/containers/";
        description = lib.mdDoc ''
          Directory where per-container state files are stored.

          By default, each container declared via `naptime.containers.<name>`
          will receive its own state subdirectory with the name `<name>`. This
          subdirectory will be automaticallly mounted into the container under
          `/mnt/state`.
        '';
        type = lib.types.path;
      };

      tailscaleAuthKeyFile = lib.mkOption {
        default = "/etc/naptime/containers/tailscale-auth-key";
        description = lib.mdDoc ''
          Path to Tailscale OAuth key for provisioning containers.

          This key must have permissions for provisioning auth keys, including
          any tags relevant to the desired containers for this host (minimum
          `tag:container`).
        '';
        type = lib.types.path;
      };
      tailscaleStateDirectory = lib.mkOption {
        default = cfg.containerSupport.stateDirectory + "/tailscale/";
        type = lib.types.path;
        description = lib.mdDoc ''
          Directory where per-container Tailscale state is stored.

          By default, each container will receive its own subdirectory which
          is automatically mounted into the container for Tailscale to use.
        '';
      };
    };

    containers = lib.mkOption {
      default = {};
      description = lib.mdDoc ''
        Wrapper around NixOS containers that injects Tailscale and other common config.

        Features:

        - Each container will be registered to Tailscale as a tagged device
          with its own Tailscale network interface.
        - Each container will receive its own state and config directories
          mounted under `/mnt/state` and `/mnt/config`, respectively.
          - If needed, these can be overridden.
        - Each container uses a private network namespace connected to a NAT'd
          bridge interface on the host machine.
      '';

      type = lib.types.attrsOf (lib.types.submodule ({name, ...}: {
        freeformType = lib.types.attrsOf lib.types.raw;

        options = {
          configDirectory = lib.mkOption {
            default = cfg.containerSupport.configDirectory + ("/" + name);
            description = lib.mdDoc ''
              Host directory where config is stored for this container.
            '';
            type = lib.types.path;
          };

          extraTailscaleTags = lib.mkOption {
            default = [];
            description = ''
              Extra tags to add when registering with Tailscale.

              Note that the OAuth key used for Tailscale must be configured
              with a superset of these tags.
            '';
            type = lib.types.listOf lib.types.str;
          };

          stateDirectory = lib.mkOption {
            default = cfg.containerSupport.stateDirectory + ("/" + name);
            description = lib.mdDoc ''
              Host directory where state is stored for this container.
            '';
            type = lib.types.path;
          };

          tailscaleStateDirectory = lib.mkOption {
            default = cfg.containerSupport.tailscaleStateDirectory + ("/" + name);
            description = lib.mdDoc ''
              Host directory where Tailscale state is stored for this container.
            '';
            type = lib.types.path;
          };
        };
      }));
    };
  };
}
