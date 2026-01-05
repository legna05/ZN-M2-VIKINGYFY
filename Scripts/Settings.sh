#!/bin/bash

# [修改点] 注释掉下方行，以恢复 Argon 原生登录界面，不再强制替换默认主题指向
# sed -i "s/luci-theme-bootstrap/luci-theme-$WRT_THEME/g" $(find ./feeds/luci/collections/ -type f -name "Makefile")

# 优化无线配置
WIFI_SH=$(find ./target/linux/{mediatek/filogic,qualcommax}/base-files/etc/uci-defaults/ -type f -name "*set-wireless.sh" 2>/dev/null)
WIFI_UC="./package/network/config/wifi-scripts/files/lib/wifi/mac80211.uc"

if [ -f "$WIFI_SH" ]; then
	sed -i "s/BASE_SSID='.*'/BASE_SSID='$WRT_SSID'/g" "$WIFI_SH"
	sed -i "s/BASE_WORD='.*'/BASE_WORD='$WRT_WORD'/g" "$WIFI_SH"
elif [ -f "$WIFI_UC" ]; then
	sed -i "s/ssid='.*'/ssid='$WRT_SSID'/g" "$WIFI_UC"
	sed -i "s/key='.*'/key='$WRT_WORD'/g" "$WIFI_UC"
	sed -i "s/country='.*'/country='CN'/g" "$WIFI_UC"
	sed -i "s/htmode='.*'/htmode='HE160'/g" "$WIFI_UC"
	sed -i "s/mu_beamformer='0'/mu_beamformer='1'/g" "$WIFI_UC"
	sed -i "s/encryption='.*'/encryption='psk2+ccmp'/g" "$WIFI_UC"
fi

# 系统配置修改
CFG_FILE="./package/base-files/files/bin/config_generate"
sed -i "s/192\.168\.[0-9]*\.[0-9]*/$WRT_IP/g" "$CFG_FILE"
sed -i "s/hostname='.*'/hostname='$WRT_NAME'/g" "$CFG_FILE"

# 增加内核优化参数
echo "net.netfilter.nf_conntrack_max=65535" >> ./package/base-files/files/etc/sysctl.conf
echo "net.core.default_qdisc=fq_codel" >> ./package/base-files/files/etc/sysctl.conf

# 强制开启核心插件
echo "CONFIG_PACKAGE_luci=y" >> ./.config
echo "CONFIG_LUCI_LANG_zh_Hans=y" >> ./.config

# 高通平台特定优化
if [[ "${WRT_TARGET^^}" == *"QUALCOMMAX"* ]]; then
	echo "CONFIG_FEED_nss_packages=n" >> ./.config
	echo "CONFIG_FEED_sqm_scripts_nss=n" >> ./.config
	
	if [[ "${WRT_CONFIG,,}" == *"ipq50"* ]]; then
		echo "CONFIG_NSS_FIRMWARE_VERSION_12_2=y" >> ./.config
	else
		echo "CONFIG_NSS_FIRMWARE_VERSION_12_5=y" >> ./.config
	fi
	
	if [[ "${WRT_CONFIG,,}" == *"wifi"* && "${WRT_CONFIG,,}" == *"no"* ]]; then
		DTS_PATH="./target/linux/qualcommax/files/arch/arm64/boot/dts/qcom/"
		find "$DTS_PATH" -type f ! -iname '*nowifi*' -exec sed -i 's/ipq\(6018\|8074\).dtsi/ipq\1-nowifi.dtsi/g' {} +
	fi
fi