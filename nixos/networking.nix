{hostname, ...}: {
  networking = {
    hostName = hostname;
    networkmanager.enable = true;
  };

  services.tailscale = {
    enable = true;
    extraDaemonFlags = [
      # Encrypt the local state using the device's TPM. This may be overkill
      # since I also use FDE, but it doesn't add much cost.
      "--encrypt-state"
    ];
    extraSetFlags = [
      # Allow other devices on tailnet to SSH to this host via Tailscale.
      # Uses Tailscale for auth and only allows connections from the tailnet;
      # this is more secure than using OpenSSH directly, and avoids leaving
      # port 22 open on public networks for a roaming device.
      #
      # Note that ACLs are administered entirely through tailscale; for
      # example, the default SSH ACL in Tailscale allows each user to SSH to
      # any of their own devices as any user (including root!). Tailscale
      # ACLs should be audited carefully.
      "--ssh"
    ];
  };
}
