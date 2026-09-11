{ ... }:
{
  security.pam.services."*".enableGnomeKeyring = true;

  security.polkit.enable = true;

  # May allow some services to use real time scheduling, which works better for
  # gaming.
  security.rtkit.enable = true;

  services.gnome.gnome-keyring.enable = true;
}
