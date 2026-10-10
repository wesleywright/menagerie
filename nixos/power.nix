{...}: {
  services.logind.settings.Login = {
    # The default behavior makes it far too easy to shut down the machine accidentally, IMO.
    HandlePowerKey = "ignore";

    # Allow the laptop to go to sleep immediately after waking up if the lid is closed again.
    # The default behavior is to wait 30 seconds to allow the system to safely react to
    # hotplugged devices without sleeping, but this makes it easy to accidentally leave the laptop
    # awake (and possibly, unlocked) unintentionally.
    HoldoffTimeoutSec = 0;
  };
}
