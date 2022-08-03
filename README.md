# Driver container image for AKS VHD

Run with 

```bash
ctr run --privileged --net-host --with-ns pid:/proc/1/ns/pid --mount type=bind,src=/opt/gpu,dst=/mnt/gpu,options=rbind --mount type=bind,src=/opt/actions,dst=/mnt/actions,options=rbind -t docker.io/alexeldeib/aks-gpu:latest /entrypoint.sh install.sh
```