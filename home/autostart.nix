{...}: {
  config.xdg.configFile = {
    # Start Discord in tray, so that I can access it quickly (and receive
    # notifications) without a window popping up intrusively.
    "autostart/discord.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=Discord
      Exec=com.discordapp.Discord --start-minimized
    '';

    # Start 1Password in tray. This allows integrations such as the browser
    # extension and the SSH agent to run and prompt for a password without
    # requring an intrusive window popup on login.
    "autostart/1password.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=1Password
      Exec=1password --silent
    '';

    # Like the above, start Signal in tray on login, to avoid intrusive
    # popups.
    "autostart/signal.desktop".text = ''
      [Desktop Entry]
      Type=Application
      Name=Signal
      Exec=org.signal.Signal --start-in-tray
    '';
  };
}
