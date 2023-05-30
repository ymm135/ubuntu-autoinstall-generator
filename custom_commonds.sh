#!/usr/bin/env bash

# 还原备份包
echo "recover backup"
tar -xvpzf /cdrom/extra-data/backup.tar.gz -C /target/ --numeric-owner

# 升级软件包
soft_package=$(ls *md5*.zip)
target_path=""
if [ -f "$soft_package" ]; then
    echo "$soft_package"

    # 还原覆盖软件
    firewall_path="/target/opt/firewall"
    if [ -d "$firewall_path" ]; then
        target_path=$firewall_path
    fi

    audit_path="/target/opt/audit"
    if [ -d "$audit_path" ]; then
        target_path=$audit_path
    fi

    if [ -d "$target_path" ]; then
        unzip -o $soft_package -d $target_path
    fi

fi
