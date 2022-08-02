#!/usr/bin/env bash
set -euo pipefail

apt update && apt install -y kmod gcc make dkms initramfs-tools linux-headers-$(uname -r) ca-certificates --no-install-recommends

DRIVER_VERSION="510.47.03"
GPU_DEST="/usr/local/nvidia"
KERNEL_NAME=$(uname -r)
LOG_FILE_NAME="/var/log/nvidia-installer-$(date +%s).log"

cp /opt/gpu/blacklist-nouveau.conf /etc/modprobe.d/blacklist-nouveau.conf
update-initramfs -u

# override default nvidia lib location which is not changeable via runfile options
mkdir /tmp/overlay
mount -t tmpfs tmpfs /tmp/overlay
mkdir /tmp/overlay/{workdir,lib64}
mkdir -p ${GPU_DEST}/lib64
mount -t overlay overlay -o lowerdir=/usr/lib/x86_64-linux-gnu,upperdir=/tmp/overlay/lib64,workdir=/tmp/overlay/workdir /usr/lib/x86_64-linux-gnu

pushd /opt/gpu
sh /opt/gpu/NVIDIA-Linux-x86_64-${DRIVER_VERSION}.run -x
popd
/opt/gpu/NVIDIA-Linux-x86_64-${DRIVER_VERSION}/nvidia-installer -s -k=$KERNEL_NAME --log-file-name=${LOG_FILE_NAME} -a --no-drm --dkms --utility-prefix="${GPU_DEST}" --opengl-prefix="${GPU_DEST}"

cp -a /tmp/overlay/lib64 ${GPU_DEST}/lib64

cp -rvT ${GPU_DEST}/bin /usr/bin
echo "${GPU_DEST}/lib64" > /etc/ld.so.conf.d/nvidia.conf
ldconfig 
umount -l /usr/lib/x86_64-linux-gnu

nvidia-modprobe -u -c0
nvidia-smi
