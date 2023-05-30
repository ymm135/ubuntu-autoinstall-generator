#!/usr/bin/env bash

# 还原备份包
echo "recover backup"
tar -xvpzf /cdrom/extra-data/backup.tar.gz -C /target/ --numeric-owner

# 升级软件包
soft_package=$(ls *md5*.zip)
if [ -f "$soft_package" ]; then
    echo "$soft_package"

    # 还原覆盖软件
    firewall_path=" unzip $soft_package -d /target/opt/firewall"
    if [ -d "$firewall_path" ]; then
        unzip $soft_package -d $firewall_path
    fi

    audit_path=" unzip $soft_package -d /target/opt/audit"
    if [ -d "$audit_path" ]; then
        unzip $soft_package -d $audit_path
    fi
fi
