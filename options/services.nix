# Configuration for custom services.
{lib, ...}: {
  options.naptime.services = {
    sleepover = {
      enable = lib.mkOption {
        default = false;
        description = lib.mdDoc ''
          Whether to enable the sleepover.naptime.gg service.

          This service acts as a user-facing gateway to all other Tailscale
          services. It provides TLS termination (with a valid, publicly signed
          ACME certificate), routing, public DNS integration, and (where
          possible) it automatically propagates Tailscale authentication to
          downstream services.

          The service runs as a `naptime.containers` container. It expects a
          `caddy.env` file placed under `/etc/naptime/containers/sleepover/`
          (or whichever config directory is configured) with at leat the
          following keys:

          - `ACME_EMAIL`: the human email address to use when provisioning TLS
            certificates via ACME providers. This email will be used if the
            ACME provider needs to contact a human.
          - `CF_API_TOKEN`: A Cloudflare API token suitable for use with
            `caddy-dns/cloudflare`.
        '';
        type = lib.types.bool;
      };

      staging = lib.mkOption {
        default = true;
        description = "Whether to use staging ACME endpoints for testing.";
        type = lib.types.bool;
      };
    };
  };
}
