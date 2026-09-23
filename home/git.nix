{pkgs, ...}: {
  programs.git = {
    enable = true;

    settings = {
      init = {
        defaultBranch = "main";
      };

      user = {
        email = "wesley@wesleywright.me";
        name = "Wesley Wright";
      };
    };
  };
}
