# Ubuntu Autoinstall Generator
A script to generate a fully-automated ISO image for installing Ubuntu onto a machine without human interaction. This uses the new autoinstall method
for Ubuntu 20.04 and newer.

## [Looking for the desktop version?](https://github.com/covertsh/ubuntu-preseed-iso-generator)

### Behavior
Check out the usage information below for arguments. The basic idea is to take an unmodified Ubuntu ISO image, extract it, add some kernel command line parameters, then repack the data into a new ISO. This is needed for full automation because the ```autoinstall``` parameter must be present on the kernel command line, otherwise the installer will wait for a human to confirm. This script automates the process of creating an ISO with this built-in.

Autoinstall configuration (disk layout, language etc) can be passed along with cloud-init data to the installer. Some minimal information is needed for
the installer to work - see the Ubuntu documentation for an example, which is also in the ```user-data.example``` file in this repository (password: ubuntu). This data can be passed over the network (not yet supported in this script), via an attached volume, or be baked into the ISO itself.

To attach via a volume (such as a separate ISO image), see the Ubuntu autoinstall [quick start guide](https://ubuntu.com/server/docs/install/autoinstall-quickstart). It's really very easy! To bake everything into a single ISO instead, you can use the ```-a``` flag with this script and provide a user-data file containing the autoinstall configuration and optionally cloud-init data, plus a meta-data file if you choose. The meta-data file is optional and will be empty if it is not specified. With an 'all-in-one' ISO, you simply boot a machine using the ISO and the installer will do the rest. At the end the machine will reboot into the new OS.

This script can use an existing ISO image or download the latest daily image from the Ubuntu project. Using a fresh ISO speeds things up because there won't be as many packages to update during the installation.

By default, the source ISO image is checked for integrity and authenticity using GPG. This can be disabled with ```-k```.

### Requirements
Tested on a host running Ubuntu 20.04.1.
- Utilities required:
    - ```xorriso```
    - ```sed```
    - ```curl```
    - ```gpg```
    - ```isolinux```

安装依赖:  

```sh
apt install -y xorriso  sed curl gpg isolinux
```

iso解压工具，用于查看iso制作情况:  
```sh
sudo apt-get install p7zip-full p7zip-rar 
```

解压操作: `7z x ubuntu-16.10-server-amd64.iso`  

### Usage
```
Usage: ubuntu-autoinstall-generator.sh [-h] [-v] [-a] [-e] [-u user-data-file] [-m meta-data-file] [-k] [-c] [-r] [-s source-iso-file] [-d destination-iso-file]

💁 This script will create fully-automated Ubuntu 20.04 Focal Fossa installation media.

Available options:

-h, --help              Print this help and exit
-v, --verbose           Print script debug info
-a, --all-in-one        Bake user-data and meta-data into the generated ISO. By default you will
                        need to boot systems with a CIDATA volume attached containing your
                        autoinstall user-data and meta-data files.
                        For more information see: https://ubuntu.com/server/docs/install/autoinstall-quickstart
-e, --use-hwe-kernel    Force the generated ISO to boot using the hardware enablement (HWE) kernel. Not supported
                        by early Ubuntu 20.04 release ISOs.
-u, --user-data         Path to user-data file. Required if using -a
-m, --meta-data         Path to meta-data file. Will be an empty file if not specified and using -a
-k, --no-verify         Disable GPG verification of the source ISO file. By default SHA256SUMS-<current date> and
                        SHA256SUMS-<current date>.gpg files in the script directory will be used to verify the authenticity and integrity
                        of the source ISO file. If they are not present the latest daily SHA256SUMS will be
                        downloaded and saved in the script directory. The Ubuntu signing key will be downloaded and
                        saved in a new keyring in the script directory.
-r, --use-release-iso   Use the current release ISO instead of the daily ISO. The file will be used if it already
                        exists.
-s, --source            Source ISO file. By default the latest daily ISO for Ubuntu 20.04 will be downloaded
                        and saved as <script directory>/ubuntu-original-<current date>.iso
                        That file will be used by default if it already exists.
-d, --destination       Destination ISO file. By default <script directory>/ubuntu-autoinstall-<current date>.iso will be
                        created, overwriting any existing file.
-ed, --extra-data       额外的文件会打包到ISO镜像内，放在extra-data目录下
```

### Example
```
user@testbox:~$ bash ubuntu-autoinstall-generator.sh -a -u user-data.example -s ubuntu-20.04.5-live-server-amd64.iso -d ubuntu-custom-super.iso -ed backup.tar.gz firewall_build_x86_6500_v1.0.0_20230511-113215_develop_md592946e9c7059585687c1ab2e0dcec1b1.zip
[2023-04-21 09:21:47] 👶 Starting up...
ubuntu-autoinstall-generator.sh: line 125: [: ../../backup.tar.gz: integer expression expected
[2023-04-21 09:21:47] 📁 Created temporary working directory /tmp/tmp.yNHF9Nk2f8
[2023-04-21 09:21:47] 🔎 Checking for required utilities...
[2023-04-21 09:21:47] 👍 All required utilities are installed.
[2023-04-21 09:21:47] ☑️ Using existing /root/ubuntu-20.04.5-live-server-amd64.iso file.
[2023-04-21 09:21:47] 🤞 Skipping verification of source ISO.
[2023-04-21 09:21:47] 🔧 Extracting ISO image...
[2023-04-21 09:21:49] 👍 Extracted to /tmp/tmp.yNHF9Nk2f8
[2023-04-21 09:21:49] 🧩 Adding autoinstall parameter to kernel command line...
[2023-04-21 09:21:49] 👍 Added parameter to UEFI and BIOS kernel command lines.
[2023-04-21 09:21:49] 🧩 Adding user-data and meta-data files...
[2023-04-21 09:21:49] 👍 Added data and configured kernel command line.
[2023-04-21 09:21:49] 🧩 Adding extra-data files...
[2023-04-21 09:21:50] 👍 Added extra-data.
[2023-04-21 09:21:50] 👷 Updating /tmp/tmp.yNHF9Nk2f8/md5sum.txt with hashes of modified files...
[2023-04-21 09:21:50] 👍 Updated hashes.
[2023-04-21 09:21:50] 📦 Repackaging extracted files into an ISO image...
[2023-04-21 09:21:56] 👍 Repackaged into /root/work/auto/ubuntu-custom-super.iso
[2023-04-21 09:21:56] ✅ Completed.
[2023-04-21 09:21:56] 🚽 Deleted temporary working directory /tmp/tmp.yNHF9Nk2f8
```

Now you can boot your target machine using ```ubuntu-custom-super.iso``` and it will automatically install Ubuntu using the configuration from ```user-data.example```.

## autoinstall说明  
https://ubuntu.com/server/docs/install/autoinstall  

### 软件包制作  

```sh
tar   \
--exclude=backup.tar.gz   \
--exclude=/lost+found   \
--exclude=/proc \
--exclude=/mnt \
--exclude=/etc/fstab \
--exclude=/sys \
--exclude=/dev \
--exclude=/boot \
--exclude=/tmp \
--exclude=/var/cache/apt/archives \
--exclude=/run \
--warning=no-file-changed \
--exclude=/home \
--exclude=/usr/lib/debug \
--exclude=/var/lib/libvirt \
--exclude=/root --exclude=/swap.img \
--exclude=/etc/netplan \
-cvpzf backup.tar.gz /
```


自定义备份指令:
```sh
tar   \
--exclude=backup.tar.gz   \
--exclude=/lost+found   \
--exclude=/proc \
--exclude=/mnt \
--exclude=/etc/fstab \
--exclude=/sys \
--exclude=/dev \
--exclude=/boot \
--exclude=/tmp \
--exclude=/var/cache/apt/archives \
--exclude=/run \
--warning=no-file-changed \
--exclude=/home \
--exclude=/usr/lib/debug \
--exclude=/var/lib/libvirt \
--exclude=/root --exclude=/swap.img \
--exclude=/etc/netplan \
--exclude=/root/ \
--exclude=/home/ \
-cvpzf backup.tar.gz /
```



### macos 制作系统U盘
```sh
# 1. 使用系统自带的磁盘管理工具格式化U盘， 选项为格式: MACOS拓展(日志格式)， 方案为GUID分区图

# 2. 取消磁盘挂载
# 终端执行以下命令
# 列出磁盘，找到你usb硬盘的盘符
diskutil list
# 输出如下：可以看到usb硬盘为/dev/disk2
/dev/disk0 (internal):
   #:                       TYPE NAME                    SIZE       IDENTIFIER
   0:      GUID_partition_scheme                         251.0 GB   disk0
   1:                        EFI EFI                     314.6 MB   disk0s1
   2:                 Apple_APFS Container disk1         250.7 GB   disk0s2
 
/dev/disk1 (synthesized):
   #:                       TYPE NAME                    SIZE       IDENTIFIER
   0:      APFS Container Scheme -                      +250.7 GB   disk1
                                 Physical Store disk0s2
   1:                APFS Volume Macintosh HD            125.9 GB   disk1s1
   2:                APFS Volume Preboot                 67.5 MB    disk1s2
   3:                APFS Volume Recovery                1.0 GB     disk1s3
   4:                APFS Volume VM                      6.4 GB     disk1s4
 
/dev/disk2 (external, physical):
   #:                       TYPE NAME                    SIZE       IDENTIFIER
   0:     FDisk_partition_scheme                        *16.0 GB    disk2
   1:                       0xEF                         6.4 MB     disk2s2
 
 
 
# 取消usb硬盘的挂载
diskutil unmountDisk /dev/disk2


# 3. 导入镜像
# 执行如下命令
# if是镜像文件路径
# of是导入的目的磁盘
# bs是读写快的大小，太小会增大io，降低效率，一般1m～2m即可。
sudo dd if=~/Downloads/CentOS-7-x86_64-DVD-1511.iso of=/dev/disk2 bs=2m
```

> ok，操作完成，等待导入完成即可。此导入需要等待一段时间，可能会比较久。耐心等待即可。  




### Thanks
This script is based on [this](https://betterdev.blog/minimal-safe-bash-script-template/) minimal safe bash template, and steps found in [this](https://discourse.ubuntu.com/t/please-test-autoinstalls-for-20-04/15250) discussion thread (particularly [this](https://gist.github.com/s3rj1k/55b10cd20f31542046018fcce32f103e) script).
The somewhat outdated Ubuntu documentation [here](https://help.ubuntu.com/community/LiveCDCustomization#Assembling_the_file_system) was also useful.


### License
MIT license.
