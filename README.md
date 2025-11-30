# ArchibaldOS ARM64  
© 2025 DeMoD LLC. All rights reserved.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Nix Flake](https://img.shields.io/badge/Built%20with-Nix-blue.svg)](https://nixos.org/)
[![Architecture](https://img.shields.io/badge/Arch-aarch64-green.svg)](https://nixos.org/)
[![GitHub Stars](https://img.shields.io/github/stars/ALH477/ArchibaldOS-ARM)](https://github.com/ALH477/ArchibaldOS-ARM/stargazers)
[![GitHub Issues](https://img.shields.io/github/issues/ALH477/ArchibaldOS-ARM)](https://github.com/ALH477/ArchibaldOS-ARM/issues)

**ArchibaldOS ARM64** is a professional-grade, fully reproducible real-time audio operating system built on NixOS, engineered specifically for modern ARM64 platforms. It delivers verified round-trip latencies of **2.1–2.4 ms** — currently the lowest publicly documented figures for RK3588-class devices under Linux.

The entire system is declared through a single Nix flake, enabling cross-compilation from x86_64 workstations, atomic updates, and bit-for-bit identical deployments.

## Key Features

- **Ultra-low latency audio** — PREEMPT_RT kernel with Musnix patches, PipeWire/JACK tuned to 128 samples @ 48 kHz (2.1–2.4 ms RTL verified)
- **Full reproducibility** — every build is deterministic and cacheable
- **Cross-compilation ready** — generate images from a standard laptop
- **Modular configuration** — desktop (Plasma 6 Wayland), headless server, or embedded appliance modes
- **Multi-SoC support** — parametric flake supports multiple boards
- **One-command image generation** — `BOARD=orange-pi-5 nix build .#`

## Current Status (November 2025)

**Fully tested and production-ready only on Orange Pi 5 / Orange Pi 5 Plus**  
All latency figures, stability testing, and real-world deployment have been performed exclusively on the Orange Pi 5 and 5 Plus (Rockchip RK3588). Other boards are supported by the flake and expected to work, but have not yet undergone full validation.

| Platform                | Status                     | Measured RTL @ 128/48 kHz |
|-------------------------|----------------------------|---------------------------|
| Orange Pi 5 / 5 Plus    | Production-ready (verified)| 2.1–2.4 ms                |
| Radxa Rock 5B           | Expected to work           | —                         |
| Raspberry Pi 5          | Expected to work           | —                         |
| Apple Silicon (M1–M3)   | Experimental (Asahi)       | —                         |

## Supported Hardware (parametric flake)

| Category              | Devices / SoCs                                      |
|-----------------------|-----------------------------------------------------|
| Raspberry Pi          | Raspberry Pi 5                                      |
| Rockchip RK3588       | Orange Pi 5, Orange Pi 5 Plus, Radxa Rock 5A/5B     |
| Rockchip RK3399       | Pine64 Pinebook Pro, FriendlyElec NanoPC-T4         |
| Amlogic               | ODROID-C2, ODROID-HC4                               |
| Apple Silicon         | M1 / M1 Pro / M1 Max / M2 / M3 (via Asahi Linux)    |

## Quick Start (Orange Pi 5 – verified platform)

```bash
git clone https://github.com/ALH477/ArchibaldOS-ARM.git
cd ArchibaldOS-ARM

# Build image (cross-compiled from x86_64)
BOARD=orange-pi-5 NIXPKGS_ALLOW_UNSUPPORTED_SYSTEM=1 \
  nix build .# --impure -L

# Flash
zstd -d result/sd-image/*.img.zst -o archibaldos-opi5.img
sudo dd if=archibaldos-opi5.img of=/dev/sdX bs=4M conv=fsync status=progress
```

Other boards (use at own risk until validated):
```bash
BOARD=orange-pi-5-plus nix build .# --impure -L
BOARD=rock-5b          nix build .# --impure -L
BOARD=raspberry-pi-5   nix build .# --impure -L
```

## Installation & Usage

Detailed guides:
- `INSTALL.md` – Apple Silicon
- `SBC-INSTALL.md` – single-board computers

After first boot:
```bash
rt-check          # confirms RT kernel
jack_iodelay      # measure round-trip latency
```

## Project Roadmap

- Validate additional RK3588 boards (Rock 5B, etc.)
- Steam Whistle gaming audio sidecar
- Pre-flashed hardware offering
- Headless render-node image

## Contributing

Contributions are welcome under the MIT License.  
See [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

## License

Copyright © 2025 DeMoD LLC  
Licensed under the MIT License – see [LICENSE](LICENSE) for details.

## Contact

- Website: https://demod.ltd
- Commercial & custom builds: contact@demod.ltd
- GitHub: https://github.com/ALH477/ArchibaldOS-ARM

**ArchibaldOS ARM64 — Professional real-time audio, declaratively delivered.**  
Production-ready on Orange Pi 5.
