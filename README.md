# Driver container image for AKS VHD

This repo provides steps to build a container image with all components required for 
Kubernetes Nvidia GPU integration. Run it as a privileged container in the host PID namespace.
It will enter the host mount namespace and install the nvidia drivers, container runtime, 
and associated libraries on the host, validating their functionality

## Build
```
docker build -f Dockerfile  -t docker.io/alexeldeib/aks-gpu:latest .
docker push docker.io/alexeldeib/aks-gpu:latest
```

## Run
```bash
mkdir -p /opt/{actions,gpu}
ctr image pull docker.io/alexeldeib/aks-gpu:latest
ctr run --privileged --net-host --with-ns pid:/proc/1/ns/pid --mount type=bind,src=/opt/gpu,dst=/mnt/gpu,options=rbind --mount type=bind,src=/opt/actions,dst=/mnt/actions,options=rbind -t docker.io/alexeldeib/aks-gpu:latest /entrypoint.sh install.sh
```

or Docker (untested...)
```bash
docker run -v /opt/gpu:/mnt/gpu -v /opt/actions:/mnt/actions docker.io/alexeldeib/aks-gpu:latest
```

Note the `--with-ns pid:/proc/1/ns/pid` and `--privileged`, as well as the bind mounts, these are key.
