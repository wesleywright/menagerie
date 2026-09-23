{ lib, ... }:
{
  options.naptime = {
    gaming.enable = lib.options.mkEnableOption "gaming support";
  };
}
