# modules/desktop.nix
{ config, pkgs, lib, ... }:

{
  # Plasma 6 + Wayland + touch-friendly defaults
  services.xserver.enable = true;

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  services.desktopManager.plasma6.enable = true;

  # Touch calibration fallback for cheap USB screens
  environment.etc."X11/xorg.conf.d/99-touchscreen.conf".text = ''
    Section "InputClass"
        Identifier "touchscreen catchall"
        MatchIsTouchscreen "on"
        Driver "libinput"
        Option "CalibrationMatrix" "1 0 0 0 1 0 0 0 1"
    EndSection
  '';

  # Make Plasma scale nicely on 5–10" panels
  environment.variables = {
    QT_AUTO_SCREEN_SCALE_FACTOR = "1";
    QT_SCALE_FACTOR = "1.5";          # tweak if needed
    PLASMA_USE_QT_SCALING = "1";
  };

  # Auto-login for SBCs (new option name)
  services.displayManager.autoLogin = {  # ← FIX: Moved out of xserver
    enable = true;
    user = "audio-user";
  };

  environment.systemPackages = with pkgs; [
    onboard           # backup on-screen keyboard (works everywhere)
  ];
}
