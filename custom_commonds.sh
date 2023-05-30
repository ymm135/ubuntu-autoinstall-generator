#!/usr/bin/env bash

# 还原备份包
echo "recover backup"
tar -xvpzf /cdrom/extra-data/backup.tar.gz -C /target/ --numeric-owner

# 升级软件包
if [ -f "/path/to/file" ]; then
    echo "File \"/path/to/file\" exists"
fi

