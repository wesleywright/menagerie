{...}: {
  # Explicitly disable SSH. This is the default; this file exists as a sanity
  # in case it is accidentally overwritten elsewhere.
  services.openssh = {enable = false;};
}
