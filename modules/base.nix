{ config, pkgs, ... }:

{
  # Timezone/Locale
  time.timeZone = "UTC";
  i18n.defaultLocale = "en_US.UTF-8";

  # Power for ARM
  powerManagement.enable = true;

  # SSH for server adaptability
  services.openssh = {
    enable = true;
    settings.PasswordAuthentication = false;  # Robust security
  };
}
