# Build Dockerfile for gw_libretro.so (TrimUI Brick / Smart Pro, tg5040 / aarch64)
#
# Based on a tg5040 toolchain (glibc/libs aligned with the console firmware).
# A generic Ubuntu build produces a .so linked against a too-recent glibc
# => crash on load (vibration + return to the rom list).
#
# Build the image:
#   docker build -t gw-pak-builder -f build/Dockerfile .
#
# Compilation (the .so is written directly into Emus/tg5040/GW.pak/ via the volume):
#   docker run --rm -v "$PWD":/project gw-pak-builder

FROM czak/tg5040-toolchain:latest

USER root
WORKDIR /project

# Tools required if missing from the image (best effort depending on the base)
RUN (apt-get update && apt-get install -y --no-install-recommends git make file ca-certificates && rm -rf /var/lib/apt/lists/*) || true

# The project is mounted as a volume in /project at run time
CMD ["bash", "./build/build-core.sh"]