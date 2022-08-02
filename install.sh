#!/usr/bin/env bash
set -euo pipefail

apt update && apt install -y kmod gcc make ca-certificates initramfs-tools --no-install-recommends

DRIVER_VERSION="510.47.03"
GPU_DEST="/usr/local/nvidia"
KERNEL_NAME=$(uname -r)
LOG_FILE_NAME="/var/log/nvidia-installer-$(date +%s).log"

cp /opt/gpu/blacklist-nouveau.conf /etc/modprobe.d/blacklist-nouveau.conf
update-initramfs -u

# override default nvidia lib location which is not changeable via runfile options
mkdir -p ${GPU_DEST}/lib64 ${GPU_DEST}/overlay-workdir
mount -t overlay -o lowerdir=/usr/lib/x86_64-linux-gnu,upperdir=${GPU_DEST}/lib64,workdir=${GPU_DEST}/overlay-workdir none /usr/lib/x86_64-linux-gnu

sh /opt/gpu/NVIDIA-Linux-x86_64-${DRIVER_VERSION}.run \
    -s \
    -k=$KERNEL_NAME \
    --log-file-name=${LOG_FILE_NAME} \
    -a \
    --no-drm \
    --dkms \
    --utility-prefix="${GPU_DEST}" \
    --opengl-prefix="${GPU_DEST}"

mv ${GPU_DEST}/bin/* /usr/bin
echo "${GPU_DEST}/lib64" > /etc/ld.so.conf.d/nvidia.conf
ldconfig 
umount -l /usr/lib/x86_64-linux-gnu

nvidia-modprobe -u -c0
nvidia-smi
