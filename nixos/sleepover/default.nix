# Service configuration for sleepover.naptime.gg.
#
# This service acts as the human-facing gateway for other tailnet services,
# including TLS termination, DNS integration, authentication (where possible),
# and more.
{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.naptime.services.sleepover;
in {
  config = lib.mkIf cfg.enable {
    naptime.containers.sleepover = {
      config = {
        # Caddy handles all HTTP and HTTPS traffic for the tailnet. It also
        # handles TLS termination and provisioning.
        services.caddy = {
          enable = true;

          dataDir = "/mnt/state/caddy";
          environmentFile = "/mnt/config/caddy.env";

          globalConfig = ''
            email {env.ACME_EMAIL}

            # Handle TLS provisioning for all configured subdomains.
            acme_dns cloudflare {env.CF_API_TOKEN}
          '';

          # Use LetsEncrypt's staging instance unless explicitly configured
          # not to. Helps to avoid issues when making large adjustments to
          # configuration.
          acmeCA = lib.mkIf cfg.staging "https://acme-staging-v02.api.letsencrypt.org/directory";

          package = pkgs.caddy.withPlugins {
            plugins = ["github.com/caddy-dns/cloudflare@v0.2.4"];
            hash = "sha256-dQvk6ezY6TQ1J7PjhCXnThF/SqVgPwBO8/RXzHCY+js=a";
          };

          virtualHosts = {
            "sleepover.naptime.gg" = {
              extraConfig = ''
                respond "Hello?"
              '';
            };
          };
        };

        systemd.tmpfiles.rules = [
          "d /mnt/state/caddy 0700 caddy caddy - -"
        ];
      };

      extraTailscaleTags = ["sleepover"];
    };
  };
}
