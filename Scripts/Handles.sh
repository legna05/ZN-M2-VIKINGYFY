#!/bin/bash

PKG_PATH="$GITHUB_WORKSPACE/wrt/package/"

# 修改 NSS 相关组件启动顺序以优化性能
NSS_DRV="../feeds/nss_packages/qca-nss-drv/files/qca-nss-drv.init"
[ -f "$NSS_DRV" ] && sed -i 's/START=.*/START=85/g' "$NSS_DRV" && echo "qca-nss-drv fixed"

NSS_PBUF="./kernel/mac80211/files/qca-nss-pbuf.init"
[ -f "$NSS_PBUF" ] && sed -i 's/START=.*/START=86/g' "$NSS_PBUF" && echo "qca-nss-pbuf fixed"

# 修复 Rust 编译环境
RUST_FILE=$(find ../feeds/packages/ -maxdepth 3 -type f -wholename "*/rust/Makefile")
if [ -f "$RUST_FILE" ]; then
	sed -i 's/ci-llvm=true/ci-llvm=false/g' "$RUST_FILE"
fi

# 修复 DiskMan 及其文件系统依赖
DM_FILE="./luci-app-diskman/applications/luci-app-diskman/Makefile"
if [ -f "$DM_FILE" ]; then
	sed -i 's/fs-ntfs/fs-ntfs3/g' "$DM_FILE"
	sed -i '/ntfs-3g-utils /d' "$DM_FILE"
	# 额外修复：确保 automount 使用 ntfs3
	[ -f "./automount/files/15-automount" ] && sed -i 's/ntfs/ntfs3/g' "./automount/files/15-automount"
fi