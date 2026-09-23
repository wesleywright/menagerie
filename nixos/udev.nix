{ ... }:

{
  # These custom rules fix some annoying behaviors I've found:
  #
  # 1. My USB hub causes Linux to wake from sleep immediately for some reason.
  #    I actually only ever want the computer to wake up if I manually press the
  #    ACPI power button on top of the chassis, so it's actually much simpler if
  #    I just disable other ACPI power signals completely.
  # 2. The udev rules packaged with Steam support all Sony controllers except
  #    for the DualSense Edge controller. According to [a GitHub comment][1],
  #    these rules have already been updated upstream and should be included in
  #    Steam itself soon (eventually?).
  #
  # [1]: https://github.com/ValveSoftware/steam-for-linux/issues/12489#issuecomment-3586299396
  services.udev.extraRules = ''
    ACTION=="add", ATTR{vendor}="0x1022", ATTR{device}="0x149c", ATTR{power/wakeup}="disabled"

    KERNEL=="hidraw*", KERNELS=="*054C:0DF2*", MODE="0660", TAG+="uaccess"
    KERNEL=="hidraw*", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="0df2", MODE="0660", TAG+="uaccess"
  '';
}
