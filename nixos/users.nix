{ ... }:

{
  users = {
    users.naptime = {
      isNormalUser = true;
      extraGroups = [ "wheel" ];
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID4g27mMLtngdZa2Qlqnn8dCMoY1i9WkJ4sW3cqWZEtu naptime@nix"
      ];
    };
  };
}
