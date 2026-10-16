{...}: {
  services.network-manager-applet.enable = true;

  # The default network-manager-applet service does not automatically restart.
  # Unfortunately, nm-applet is prone to race conditions with XWayland startup
  # and other oddities. This snippet explicitly adds restart-on-failure to
  # nm-applet to smooth out these edge cases.
  systemd.user.services.network-manager-applet = {
    Service = {
      Restart = "on-failure";
      RestartSec = "1s";
    };
  };
}
