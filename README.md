# Game & Watch (GW.pak) for NextUI — TrimUI Brick

This pak lets you play **Game & Watch** simulators (and other handheld LCD games converted from MADrigal's simulators) on the **TrimUI Brick** (and Smart Pro, `tg5040` platform) under **NextUI** or **MinUI**, via the libretro core [gw-libretro](https://github.com/libretro/gw-libretro) launched by `minarch`.

Since this is an "embedded libretro core" type pak, you get all of NextUI's standard features: resume from the menu, quicksave / auto-resume, in-game menu, etc.

## Installation

1. Download the `GW.pakz` archive from the [Releases](github.com/pawndev/Game-Watch-NextUI/releases/latest) page.
2. Extract it **to the root of your SD card** (the `Emus/` and `Roms/` folders will merge with your existing ones).
3. You should end up with:

```
SDCARD/
├── Emus/
│   └── tg5040/
│       └── GW.pak/
│           ├── launch.sh
│           └── gw_libretro.so
└── Roms/
    └── Game & Watch (GW)/
        └── (your .mgw files here)
```

4. Reinsert the SD card: "Game & Watch" appears in the list of systems.

## Games (.mgw)

The core does not read Nintendo ROMs, but **`.mgw`** files: [MADrigal](http://www.madrigaldesign.it/sim/)'s simulators converted for libretro. Put your `.mgw` files in `Roms/Game & Watch (GW)/`.

## Building the core yourself

The easiest way is through Docker, it uses a toolchain matching the Brick's firmware, so you don't have to install anything:

```bash
./build/docker-build.sh   # or: mise run docker-build
```

This clones `gw-libretro`, cross-compiles it for aarch64 and drops the core into `Emus/tg5040/GW.pak/`. Then zip everything into a `.pakz` ready to drop on the SD card:

```bash
./build/package.sh        # or: mise run package
```

If you already have a tg5040 toolchain on your machine, you can skip Docker and run `./build/build-core.sh` directly. Just don't build with a stock `gcc-aarch64-linux-gnu` from a recent distro: the resulting `.so` links against a glibc newer than the firmware's, and the pak will crash on launch (strong vibration, straight back to the rom list).

## Automated release (GitHub Actions)

The **Build & Release GW.pak** workflow is triggered manually:

1. **Actions** tab -> **Build & Release GW.pak** -> **Run workflow**.
2. Choose the **branch** and fill in the **version** (e.g. `v1.0.0`).
3. The workflow compiles the core, assembles the pak zip and publishes a GitHub release (with SHA-256 checksum) from the chosen branch.

## Credits & licenses

- [gw-libretro](https://github.com/libretro/gw-libretro) — libretro core for Game & Watch simulators (zlib license).
- [MADrigal](http://www.madrigaldesign.it/sim/) — original simulators.
- [NextUI](https://github.com/LoveRetro/NextUI) / MinUI by Shaun Inman — frontend & minarch.
- Project structure inspired by [Zelda-Classic-MinUI](https://github.com/cobaltgit/Zelda-Classic-MinUI) by [cobaltgit](github.com/cobaltgit).

The gw-libretro core is under the **zlib** license (see `LICENSE`).