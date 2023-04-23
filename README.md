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
user@testbox:~$ bash ubuntu-autoinstall-generator.sh -a -u user-data.example -ed backup.tar.gz -d ubuntu-custom-super.iso
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

### Thanks
This script is based on [this](https://betterdev.blog/minimal-safe-bash-script-template/) minimal safe bash template, and steps found in [this](https://discourse.ubuntu.com/t/please-test-autoinstalls-for-20-04/15250) discussion thread (particularly [this](https://gist.github.com/s3rj1k/55b10cd20f31542046018fcce32f103e) script).
The somewhat outdated Ubuntu documentation [here](https://help.ubuntu.com/community/LiveCDCustomization#Assembling_the_file_system) was also useful.


### License
MIT license.
