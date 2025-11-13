{ config, pkgs, lib, ... }:

let
  audioPackages = with pkgs; [
    audacity fluidsynth musescore guitarix
    csound csound-qt faust portaudio rtaudio supercollider qjackctl
    surge-XT zrythm carla puredata cardinal helm zynaddsubfx vmpk qmidinet 
    faust2alsa faust2csound faust2jack dragonfly-reverb calf
  ];
in {
  musnix.enable = true;
  musnix.kernel.realtime = true;
  musnix.kernel.packages = pkgs.linuxPackages_latest_rt;
  musnix.alsaSeq.enable = true;
  musnix.rtirq.enable = true;
  musnix.das_watchdog.enable = true;

  hardware.pulseaudio.enable = false;

  services.pipewire = {
    enable = true;
    alsa.enable = true;
    pulse.enable = true;
    jack.enable = true;
    extraConfig.pipewire."92-low-latency" = {
      "context.properties" = {
        "default.clock.rate" = 48000;
        "default.clock.quantum" = 32;
        "default.clock.min-quantum" = 32;
        "default.clock.max-quantum" = 2048;
      };
    };
  };

  security.rtkit.enable = true;

  security.pam.loginLimits = [
    { domain = "@audio"; item = "rtprio"; type = "-"; value = 95; }
    { domain = "@audio"; item = "memlock"; type = "-"; value = "unlimited"; }
    { domain = "@audio"; item = "nice"; type = "-"; value = -19; }
    { domain = "@audio"; item = "nofile"; type = "soft"; value = 99999; }
    { domain = "@audio"; item = "nofile"; type = "hard"; value = 99999; }
  ];

  boot.kernelParams = [
    "threadirqs"
    "isolcpus=1-3"
    "nohz_full=1-3"
  ];

  boot.kernel.sysctl = {
    "vm.swappiness" = lib.mkForce 0;
    "fs.inotify.max_user_watches" = 600000;
  };

  environment.etc."sysctl.d/99-audio.conf".text = ''
    dev.rtc.max-user-freq = 2048
  '';

  powerManagement.cpuFreqGovernor = "performance";

  environment.etc."asound.conf".text = ''
    defaults.pcm.dmix.rate 48000
    defaults.pcm.dmix.format S32_LE
    defaults.pcm.dmix.buffer_size 32
  '';

  environment.etc."ardour6/ardour.rc".text = ''
    <JACK buffer-size="32" sample-rate="48000" periods="2"/>
  '';

  systemd.services."disable-non-essential" = {
    description = "Disable non-essential services for RT audio";
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.systemd}/bin/systemctl stop NetworkManager bluetooth";
      RemainAfterExit = true;
    };
  };

  boot.kernelModules = [ "snd_usb_audio" "usbhid" "usbmidi" ];
  boot.extraModprobeConfig = ''
    options snd_usb_audio nrpacks=1 low_latency=1
  '';

  environment.systemPackages = audioPackages;
}
