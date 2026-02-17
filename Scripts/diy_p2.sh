#!/bin/bash

feeds_path="/home/runner/work/ZN-M2-VIKINGYFY/ZN-M2-VIKINGYFY/wrt/scripts/feeds"

#优先安装 ddns-go 源
#./scripts/feeds update ddns-go
$feeds_path install -a -f -p ddns_go
