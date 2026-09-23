{ ... }:

{
  programs.virt-manager.enable = true;
  users.groups.libvirtd.members = [ "naptime" ];
  virtualisation.libvirtd = {
    enable = true;
    qemu.swtpm.enable = true;
  };
}
