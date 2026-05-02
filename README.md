# OpenWrt x86_64 Build Recipe

This repository contains the files needed to reproduce the local OpenWrt x86_64 firmware build in GitHub Actions.

## Structure

- `.github/workflows/build-openwrt.yml`: GitHub Actions build workflow.
- `configs/x86_64.config`: OpenWrt seed config copied to `.config` before `make defconfig`.
- `custom-packages.txt`: external package manifest. Each non-comment line is `repo dest [ref]`.
- `scripts/clone-custom-packages.sh`: clones manifest entries into the OpenWrt tree.
- `scripts/apply-openwrt-patches.sh`: applies local patches to the cloned OpenWrt tree.
- `patches/openwrt/010-fix-provider-loops.patch`: removes provider/conflict definitions that create Kconfig recursive dependency chains.
- `patches/openwrt/020-move-ttyd-menu.patch`: moves `luci-app-ttyd` from LuCI Services to System below Administration.

## Build Flow

1. Clone OpenWrt.
2. Checkout the latest stable `v*` tag, excluding release candidates.
3. Clone custom packages into `package/custom/`.
4. Update and install feeds.
5. Apply OpenWrt patches.
6. Copy `configs/x86_64.config` to `.config` and run `make defconfig`.
7. Download sources.
8. Build with all available cores, then retry single-threaded if the first build fails.

Build logs are uploaded as artifacts only when the workflow fails. Firmware artifacts are uploaded when the workflow succeeds.
