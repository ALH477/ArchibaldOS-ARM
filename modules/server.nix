{ config, pkgs, ... }:

{
  # Disable GUI
  services.xserver.enable = false;
  services.getty.autologinUser = null;  # No auto-login

  # Firewall & Monitoring
  networking.firewall.enable = true;
  services.prometheus.enable = true;  # Optional metrics

  # Server Packages
  environment.systemPackages = with pkgs; [ nginx docker ];
  virtualisation.docker.enable = true;
}
