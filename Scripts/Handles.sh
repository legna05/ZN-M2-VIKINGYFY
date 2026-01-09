#!/bin/bash

# 路径定义
PKG_PATH="$GITHUB_WORKSPACE/wrt/package"
FEED_PATH="$GITHUB_WORKSPACE/wrt/feeds"

# 1. NSS 相关组件启动顺序优化 (确保网络栈就绪)
NSS_DRV_FILE=$(find "$FEED_PATH" -type f -name "qca-nss-drv.init" | head -n 1)
if [ -f "$NSS_DRV_FILE" ]; then
    sed -i 's/START=.*/START=85/g' "$NSS_DRV_FILE"
fi

# 2. 彻底抹除无线残留 (驱动、配置与 UI)
find "$PKG_PATH" -type f -name "mac80211.sh" -delete
rm -f "$PKG_PATH/base-files/files/etc/config/wireless"

# [100% 优化] 屏蔽 LuCI 状态页中的无线菜单，防止前端报错
STATUS_LUA="./feeds/luci/modules/luci-mod-status/luasrc/controller/admin/status.lua"
if [ -f "$STATUS_LUA" ]; then
    sed -i '/"admin", "network", "wireless"/d' "$STATUS_LUA"
fi

# 3. 清理无线相关插件目录
find "$FEED_PATH/luci/" -type d -name "*luci-app-mtwifi*" | xargs rm -rf
find "$FEED_PATH/luci/" -type d -name "*luci-app-wifi-schedule*" | xargs rm -rf

# 4. 提升有线并发性能 (内核参数)
SYSCTL_CONF="$PKG_PATH/base-files/files/etc/sysctl.conf"
if ! grep -q "nf_conntrack_max" "$SYSCTL_CONF"; then
    echo "net.netfilter.nf_conntrack_max=131072" >> "$SYSCTL_CONF"
fi

# 5. 修复 Rust 编译环境
RUST_FILE=$(find "$FEED_PATH" -maxdepth 4 -type f -wholename "*/rust/Makefile" | head -n 1)
if [ -n "$RUST_FILE" ]; then
    sed -i 's/ci-llvm=true/ci-llvm=false/g' "$RUST_FILE"
fi