{...}: {
  naptime = {
    containerSupport.hostInterface = "wlp4s0";
    gaming.enable = true;

    # I don't want to host this on mudkip long term, but it's useful for now.
    services.sleepover = {
      enable = true;
      staging = false;
    };
  };
}
