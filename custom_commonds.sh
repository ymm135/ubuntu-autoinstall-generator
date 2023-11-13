#!/usr/bin/env bash
# 清除/data/数据
echo "clean /data"
rm -fr /target/data/*

# 还原备份包
echo "recover backup"
tar -xpzf /cdrom/extra-data/backup.tar.gz -C /target/ --numeric-owner

# 升级软件包
soft_package=$(ls /cdrom/extra-data/*md5*.tar.gz)
target_path=""
if [ -f "$soft_package" ]; then
    echo "$soft_package"

    # 还原覆盖软件
    firewall_path="/target/opt/netvine/origin/"
    if [ -d "$firewall_path" ]; then
        target_path=$firewall_path
    fi

    if [ -d "$target_path" ]; then
        # 先删除历史数据
        rm -fr ${target_path}*
        tar -zxf $soft_package -C $target_path
    fi
fi

# 执行自定义指令
baseDir="/cdrom/extra-data/resource"
for script in $baseDir/shell/*.sh; do
    if [ -f "$script" ]; then
        echo "Running script: $script"
        bash -x "$script"
    fi
done

# 覆盖文件
rsync -av $baseDir/override/* /target/
