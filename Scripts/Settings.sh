#!/bin/bash

# 1. 基础系统设置 (使用更强健的正则匹配)
CFG_FILE="./package/base-files/files/bin/config_generate"
if [ -f "$CFG_FILE" ]; then
    # 精确匹配 lan) 后的 ipad 变量赋值
    sed -i "s/lan) ipad=[^}]*/lan) ipad=\${2:-$WRT_IP}/" "$CFG_FILE"
    # 修改默认主机名
    sed -i "s/hostname='.*'/hostname='$WRT_NAME'/g" "$CFG_FILE"
fi

# 2. 核心组件冲突解决 (先删后加，确保 dnsmasq-full 唯一性)
sed -i '/CONFIG_PACKAGE_dnsmasq/d' .config
echo "CONFIG_PACKAGE_dnsmasq-full=y" >> .config
echo "CONFIG_LUCI_LANG_zh_Hans=y" >> .config

# 3. 高通 Qualcommax 平台稳定性加固
if [[ "${WRT_TARGET^^}" == *"QUALCOMMAX"* ]]; then 
    sed -i '/CONFIG_FEED_sqm_scripts_nss/d' .config
    echo "CONFIG_FEED_sqm_scripts_nss=n" >> .config 
    echo "CONFIG_PACKAGE_nss-firmware-ipq6018=y" >> .config
    echo "CONFIG_PACKAGE_kmod-qca-nss-drv=y" >> .config
    echo "CONFIG_PACKAGE_kmod-qca-nss-ecm=y" >> .config
fi

# 4. 追加手动插件
[ -n "$WRT_PACKAGE" ] && echo "$WRT_PACKAGE" >> .config

exit 0