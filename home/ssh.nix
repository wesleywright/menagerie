{...}: {
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      "*" = {};
    };
    extraConfig = ''
      IdentityAgent ~/.1password/agent.sock
    '';
  };
}
