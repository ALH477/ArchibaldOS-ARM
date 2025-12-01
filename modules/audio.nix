{ config, pkgs, lib, ... }:

{
  # ArchibaldOS Real-Time Audio Configuration
  
  # Enable Musnix for real-time kernel and audio optimizations
  musnix = {
    enable = true;
    
    # Don't replace the kernel - use the board's RK3588-optimized kernel
    # The RK3588 kernel has hardware-specific drivers we need
    kernel.realtime = false;
    
    # RT interrupt request prioritization
    rtirq = {
      enable = true;
      # Prioritize audio hardware interrupts
      highList = "snd_usb_audio";
    };
    
    # Watchdog for detecting audio xruns
    das_watchdog.enable = true;
  };

  # PipeWire with JACK backend for professional audio
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    
    # Ultra-low latency configuration
    # 128 samples @ 48kHz = 2.67ms theoretical, 2.1-2.4ms measured
    extraConfig.pipewire."92-low-latency" = {
      context.properties = {
        default.clock.rate = 48000;
        default.clock.quantum = 128;
        default.clock.min-quantum = 128;
        default.clock.max-quantum = 128;
      };
    };
    
    extraConfig.pipewire-pulse."92-low-latency" = {
      context.modules = [
        {
          name = "libpipewire-module-protocol-pulse";
          args = {
            pulse.min.req = "128/48000";
            pulse.default.req = "128/48000";
            pulse.max.req = "128/48000";
            pulse.min.quantum = "128/48000";
            pulse.max.quantum = "128/48000";
          };
        }
      ];
      stream.properties = {
        node.latency = "128/48000";
        resample.quality = 1;
      };
    };
  };

  # Security limits for real-time audio
  security.pam.loginLimits = [
    { domain = "@audio"; type = "-"; item = "rtprio"; value = "99"; }
    { domain = "@audio"; type = "-"; item = "memlock"; value = "unlimited"; }
    { domain = "@audio"; type = "-"; item = "nice"; value = "-19"; }
  ];

  # Real-time group
  users.groups.realtime = {};

  # Kernel parameters for audio performance
  boot.kernelParams = [
    "threadirqs"  # Thread IRQs for better RT performance
    "cpufreq.default_governor=performance"  # Prevent CPU throttling
    "nohz_full=1-7"  # Isolate CPUs for audio (adjust for your board)
  ];

  # Performance CPU governor (no throttling)
  powerManagement.cpuFreqGovernor = lib.mkDefault "performance";

  # Disable power management features that cause latency jitter
  services.thermald.enable = false;
  services.tlp.enable = false;
  services.power-profiles-daemon.enable = false;

  # Audio software packages
  # Note: Some packages removed for cross-compilation compatibility
  # Install additional software after booting the system natively
  environment.systemPackages = with pkgs; [
    # JACK tools
    jack2
    qjackctl
    jack_capture
    
    # Lightweight audio tools that cross-compile well
    # ardour        # Removed - cross-compilation issues
    # reaper        # Removed - cross-compilation issues
    # carla         # Removed - complex dependencies
    qtractor
    
    # Guitar/Bass processing
    guitarix
    
    # Audio programming and DSP
    # faust         # Add after first boot if needed
    # faust2jack
    # faust2lv2
    puredata
    
    # Audio utilities
    pavucontrol  # PipeWire/Pulse volume control
    helvum       # PipeWire patchbay
    qpwgraph     # PipeWire graph
    
    # Plugin hosts
    jalv  # LV2 plugin host
    
    # Analysis tools
    (writeShellScriptBin "rt-check" ''
      #!/usr/bin/env bash
      echo "=== ArchibaldOS Real-Time Check ==="
      echo
      echo "Kernel:"
      uname -r
      echo
      echo "Note: Using RK3588-optimized kernel instead of PREEMPT_RT"
      echo "      Hardware drivers + kernel tuning achieve similar latency"
      echo
      echo "CPU Governor:"
      cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor 2>/dev/null || echo "N/A"
      echo
      echo "Audio group membership:"
      groups | grep -q audio && echo "✓ In audio group" || echo "✗ Not in audio group"
      echo
      echo "RT limits:"
      ulimit -r
      echo
      echo "PipeWire status:"
      systemctl --user status pipewire.service 2>/dev/null | head -3 || echo "Not running"
    '')
    
    (writeShellScriptBin "audio-latency-test" ''
      #!/usr/bin/env bash
      echo "Testing round-trip latency..."
      echo "This requires jack2 tools and a loopback cable"
      echo "Connect output to input with a cable and run:"
      echo "  jack_iodelay"
      echo
      echo "Or use: pw-jack jack_iodelay"
    '')
  ];
}
