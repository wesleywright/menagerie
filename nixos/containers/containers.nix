# Handles mapping `naptime.containers.<name>` into NixOS's native
# `containers.<name>` config (see `options/containers.nix`).
#
# This specifically handles:
#
# - Ensuring state and config directories exist.
# - Bind mounting said state and config directories into the container.
# - Configuring the container to use the `containerSupport` bridge interface,
#   including configuring access to internet and DNS.
# - Tailscale setup for each container (so that each container is registered
#   as a distinct tag-managed device in Tailscale, complete with its own name
#   and IP).
# - Setting sane boilerplate defaults (such as system state version).
{
  config,
  lib,
  ...
}: let
  cfg = config.naptime;

  # Options that should NOT be forwarded from `naptime.containers.<name>` to
  # `containers.<name>` (either because they are custom or because we merge
  # them manually).
  optionsToRemove = [
    # Merged using NixOS module imports for better DX
    "config"

    # Custom options that I manage
    "extraTailscaleTags"
    "configDirectory"
    "stateDirectory"
    "tailscaleStateDirectory"
  ];

  # The base NixOS config for each container. This is used as the first import
  # of the final container's NixOS config.
  baseConfig = name: container: {
    networking = {
      # Tell the container to set IP traffic through the bridge interface.
      defaultGateway = cfg.containerSupport.bridgeAddress;
      # Workaround for DNS issues (https://github.com/NixOS/nixpkgs/issues/162686)
      useHostResolvConf = lib.mkForce false;
    };

    services = {
      # Workaround for DNS issues (https://github.com/NixOS/nixpkgs/issues/162686)
      resolved.enable = true;

      tailscale = {
        enable = true;

        authKeyFile = "/run/secrets/tailscale-auth-key";
        authKeyParameters = {
          # Defaults to true. Our containers are stateful so we don't need
          # this (and also ephemeral containers have extra limits on the free
          # plan).
          ephemeral = false;
        };

        extraSetFlags = ["--ssh"];
        extraUpFlags = let
          allTags = ["container"] ++ container.extraTailscaleTags;
          prefixedTags = map (tag: "tag:${tag}") allTags;
          joinedTags = lib.concatStringsSep "," prefixedTags;
        in ["--advertise-tags=${joinedTags}"];
      };
    };

    # This doesn't matter too much since the container is ephemeral and is
    # completely re-created whenever the config is changed, but setting it
    # explicitly silences some warnings.
    system.stateVersion = "26.05";
  };

  # The base NixOS container config, before any overrides from the caller.
  makeBaseContainer = name: container: {
    # TODO: merging this key would be annoying.
    additionalCapabilities = [
      # Needed by Tailscale.
      "CAP_NET_ADMIN"
      "CAP_NET_RAW"
    ];

    autoStart = true;

    bindMounts = {
      "/mnt/config" = {
        hostPath = container.configDirectory;
        isReadOnly = true;
      };
      "/mnt/state" = {
        hostPath = container.stateDirectory;
        isReadOnly = false;
      };
      "/run/secrets/tailscale-auth-key" = {
        hostPath = cfg.containerSupport.tailscaleAuthKeyFile;
        isReadOnly = true;
      };
      "/var/lib/tailscale" = {
        hostPath = container.tailscaleStateDirectory;
        isReadOnly = false;
      };
    };

    # Needed by Tailscale.
    enableTun = true;

    # Delete everything when the container is stopped or recreated, except
    # for data stored in bind mounts. Makes it easier to ensure that the config
    # is reproducible, and avoids accumulating cruft.
    ephemeral = true;

    hostBridge = cfg.containerSupport.bridgeInterface;

    # TODO: allocate IPs automatically (but statically). One option is to map
    # the container attr set into an attr set of name -> IP, where the last
    # octet is determined by the sort order of the container.
    localAddress = "10.0.0.2/24";

    # Good for security, and particularly helpful for avoiding clobbering the
    # host's Tailscale config.
    privateNetwork = true;
  };

  # Combine a `naptime.containers.<name>` definition with the base configs above.
  makeContainer = name: container: let
    everythingButConfig =
      lib.recursiveUpdate
      (makeBaseContainer name container)
      (removeAttrs container optionsToRemove);
    config = {
      imports = [
        (baseConfig name container)
        container.config
      ];
    };
  in
    everythingButConfig // {inherit config;};

  tmpfilesRule = {
    d = {
      user = "root";
      group = "root";
      # TODO: is this the most appropriate setting? I want sensitive files to
      # be hidden from unprivileged users without needing to tweak permissions
      # for every directory/file, but this may be overlly restrictive.
      mode = "0711";
      age = "-";
    };
  };
  makeTmpfilesRules = name: container: {
    ${container.configDirectory} = tmpfilesRule;
    ${container.stateDirectory} = tmpfilesRule;
    ${container.tailscaleStateDirectory} = tmpfilesRule;
  };
in {
  containers = builtins.mapAttrs makeContainer cfg.containers;

  # Ensure that state and config directories exist s othat they can be bind
  # mounted.
  systemd.tmpfiles.settings = {
    "naptime-containers" =
      lib.concatMapAttrs
      makeTmpfilesRules
      cfg.containers;
  };
}
