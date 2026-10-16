{...}: {
  security = {
    # Enable display manager support for unlocking gnome-keyring without
    # a redundant password prompt. Specifically, gdm is able to unlock the
    # keyring using the LUKS password.
    pam.services."*".enableGnomeKeyring = true;

    # Required for gtklock to be configured from the home-manager side.
    pam.services.gtklock.enable = true;

    # Enable polkit, which allows various programs to prompt for privilege
    # escalation interactively.
    polkit.enable = true;

    # May allow some services to use real time scheduling, which works better for
    # gaming.
    rtkit.enable = true;
  };

  services = {
    # The fingerprint support on Framework laptops is nice, but using it has
    # two issues in practice:
    #
    # 1. The default PAM configs require a fingerprint *and* a password to log
    #    in. This is both annoying and risky; if the fingerprint reader
    #    malfunctions (or if my physical fingerprint is unavailable for any
    #    reason), then I won't be able to log in.
    # 2. Fingerprints are considered unsafe for use cases like polkit and sudo,
    #    specifically due to a lack of security attention. This makes it easy
    #    for an unprivileged process to hijack a fingerprint scanning attempt
    #    from a legitimate process; see CVE-2024-37408.
    fprintd.enable = false;

    # Primarily used for connecting to WiFi. Otherwise I prefer to use
    # 1Password.
    gnome.gnome-keyring.enable = true;
  };
}
