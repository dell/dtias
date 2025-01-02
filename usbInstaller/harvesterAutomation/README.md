# harvesterAutomation

The automation discussed below will separate the Harvester installation and the configuration into separate stages.
- The Installation will select the 'Install Harvester Binaries Only' option' which will install just the Harvester binaries with minimal configuration.
- The Configuration which can be passed as `#cloud-config` to be read on first boot.

It is possible to do this all in one step by modifying Kernel arguments in Grub, but that is not as clean of an approach and requires a [modification](https://github.com/harvester/harvester-installer/pull/872) to Harvester.

## Known Issues

- There is a bug in Harvester that prevents this process from working if you are using DHCP. To fix, download the Taylor Shrauner-Biggs rebuild of Harvester. A PR has been submitted and can be tracked [here](https://github.com/harvester/harvester-installer/pull/876)

- There is a [issue](https://github.com/harvester/harvester/issues/7017) on certain systems where Elemental attempts to look for valid `cloud-config` before all physical devices
   have been enumerated. This results in an error, `Invalid configuration: unknown mode:` upon first boot. The work around is to switch to the console (Alt+Ctrl+F2), 
   login (rancher/rancher), create a file, /oem/91_workaround.yaml, with the following contents and then reboot:

- If auto install of binaries only, configuration must be auto, no way to get menu presented

```bash
name: "Rootfs Layout Settings"
stages:
  initramfs:
    - name: "Pull data from provider"
      datasource:
        providers: ["cdrom"]
        path: "/oem"
```

- The above race condition may affect the single ISO approach from working. Until a permanent fix is implemented, use the dual ISO approach.

- Due to how Harvester configures it's networking, your target node MUST have it's identified network interface connected. Link light is all that is required and this could potentially be over come with a ethernet loopback plug.

## To Do
- Create Cert for Harvester
- Update instructions to add `cloud-init` as a second partition which will have it's own label, allowing the single or dual ISO approach to never conflict with the installer label
- Configure ArgoCD to trust the registry
- Leverage keycloak or authelia for authentication
- Configure DHCP (baked into Harvester)
- Configure Monitoring (Harvester option)
- Implement provisions stack

## Build Custom Graphcial Deskstop Container
[x11docker](https://github.com/mviereck/x11docker) is a tool that will pair a graphcial desktop container to a TTY on a host. This will provide a graphcial environment on Harvester where a browser can be ran to access any applications that are installed. 

Create x11docker directory.
```bash
mkdir x11docker
```

Create Dockerfile to build container. The Dockerfile for this container can be found is based off [x11docker/xfce Dockerfile](https://github.com/mviereck/dockerfile-x11docker-xfce/blob/master/Dockerfile) with the exception of upgrading the OS and adding Firefox.
```bash
cat > x11docker/Dockerfile << EOF
FROM debian:bookworm

RUN apt-get update && apt-mark hold iptables && \
    env DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      dbus-x11 \
      psmisc \
      xdg-utils \
      x11-xserver-utils \
      x11-utils && \
    env DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      xfce4 && \
    env DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      libgtk-3-bin \
      libpulse0 \
      mousepad \
      xfce4-notifyd \
      xfce4-taskmanager \
      xfce4-terminal && \
    env DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      xfce4-battery-plugin \
      xfce4-clipman-plugin \
      xfce4-cpufreq-plugin \
      xfce4-cpugraph-plugin \
      xfce4-diskperf-plugin \
      xfce4-datetime-plugin \
      xfce4-fsguard-plugin \
      xfce4-genmon-plugin \
      xfce4-indicator-plugin \
      xfce4-netload-plugin \
      xfce4-places-plugin \
      xfce4-sensors-plugin \
      xfce4-smartbookmark-plugin \
      xfce4-systemload-plugin \
      xfce4-timer-plugin \
      xfce4-verve-plugin \
      xfce4-weather-plugin \
      xfce4-whiskermenu-plugin && \
    env DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      libxv1 \
      mesa-utils \
      mesa-utils-extra && \
    env DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
      firefox-esr && \
    sed -i 's%<property name="ThemeName" type="string" value="Xfce"/>%<property name="ThemeName" type="string" value="Raleigh"/>%' /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml

# disable xfwm4 compositing if X extension COMPOSITE is missing and no config file exists
RUN Configfile="~/.config/xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml" && \
echo "#! /bin/bash\n\
xdpyinfo | grep -q -i COMPOSITE || {\n\
  echo 'x11docker/xfce: X extension COMPOSITE is missing.\n\
Window manager compositing will not work.\n\
If you run x11docker with option --nxagent,\n\
you might want to add option --composite.' >&2\n\
  [ -e $Configfile ] || {\n\
    mkdir -p $(dirname $Configfile)\n\
    echo '<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n\
<channel name=\"xfwm4\" version=\"1.0\">\n\
\n\
  <property name=\"general\" type=\"empty\">\n\
    <property name=\"use_compositing\" type=\"bool\" value=\"false\"/>\n\
  </property>\n\
</channel>\n\
' > $Configfile\n\
  }\n\
}\n\
startxfce4\n\
" > /usr/local/bin/start && \
chmod +x /usr/local/bin/start
EOF
```

Build container.
```bash
docker build -t kpro/xfce x11docker/.
```

Save container.
```bash
docker save kpro/xfce:latest -o x11docker/xfce.tar
```

## Create Hauler Manifests To Gather Artifacts

Assuming your target is fully airgapped, the first thing you need to do is collect the necessary images and charts that you are planning to use (all images for Harvester are already included on the ISO). For this, we are going to leverage [Hauler](http://hauler.dev).

Create Hauler directory:
```bash
mkdir hauler
```

Create a seeder images manifest. This will include the core images that are required to bring up a registry and will be loaded directly to the container runtime.
```bash
cat > hauler/seeder_images.yaml << EOF
apiVersion: content.hauler.cattle.io/v1alpha1
kind: Images
metadata:
  name: hauler-seeder-images
  annotations:
    hauler.dev/platform: linux/amd64
spec:
  images:
    - name: ghcr.io/project-zot/zot-linux-amd64:v2.1.2-rc3
    - name: quay.io/jetstack/cert-manager-cainjector:v1.16.2
    - name: quay.io/jetstack/cert-manager-controller:v1.16.2
    - name: quay.io/jetstack/cert-manager-webhook:v1.16.2
    - name: quay.io/jetstack/cert-manager-startupapicheck:v1.16.2
EOF
```

Create a seeder files manifest. This will include the Helm Charts for the core images. Note: Hauler does support collecting Helm Charts as their own type, but they can't be exported as a file later
```bash
cat > hauler/seeder_files.yaml << EOF
apiVersion: content.hauler.cattle.io/v1alpha1
kind: Files
metadata:
  name: hauler-seeder-files
spec:
  files:
    - path: https://github.com/project-zot/helm-charts/releases/download/zot-0.1.65/zot-0.1.65.tgz
      name: registry.tgz
    - path: https://charts.jetstack.io/charts/cert-manager-v1.16.2.tgz
      name: cert-manager.tgz
EOF
```

Create a collection manifest. This will include any applications you want deployed on the system.
```bash
cat > hauler/collection.yaml << EOF
apiVersion: content.hauler.cattle.io/v1alpha1
kind: Images
metadata:
  name: hauler-collection-images
  annotations:
    hauler.dev/platform: linux/amd64
spec:
  images:
    - name: quay.io/argoproj/argocd:v2.13.0
    - name: ghcr.io/dexidp/dex:v2.41.1
    - name: public.ecr.aws/docker/library/redis:7.2.4-alpine
    - name: boomstack/tetris:0.1.8
    - name: library/nginx:1.27.3
    - name: x11docker/xserver
---
apiVersion: content.hauler.cattle.io/v1alpha1
kind: Charts
metadata:
  name: hauler-content-charts-example
spec:
  charts:
    - name: argo-cd
      repoURL: https://argoproj.github.io/argo-helm
      version: 7.7.0
    - name : tetris
      repoURL: https://rancher.github.io/rodeo
      version: 0.1.9
---
apiVersion: content.hauler.cattle.io/v1alpha1
kind: Files
metadata:
  name: hauler-collection-files
spec:
  files:
    - path: https://raw.githubusercontent.com/mviereck/x11docker/master/x11docker
    - path: x11docker/xfce.tar
EOF
```

## Automate 'Install Harvester Binaries Only'

In order to automate the Harvester installation, it is necessary to update the `grub.cfg` configuration on the Harvester ISO. The below is the default grub.cfg from v1.3.2. 
The first `menuentry` has been added to automate the Install Binaries configuration. It is a copy of the now second `menuentry` with the exception of a new 
title and additional Kernel arguments:
- `harvester.scheme_version=1`
- `harvester.install.skipchecks=true`
- `harvester.install.mode=install`
- `harvester.install.device=<disk_device>`
- `harvester.install.automatic=true`

`harvester.install.device=` needs to be set to the disk device that you system has (/dev/sda, /dev/nvme, etc.).
If you incorrectly specify your device location during this step, you can edit the grub options at the install menu to make any one-time corrections by interrupting the installer grub menu and modifying the `Install Binaries Only` entry.

Specify disk type of target system.
```bash
disk_device=/dev/nvme0n1
```

Generate new Harvester grub.cfg
```bash
cat > grub.cfg << EOF
search --no-floppy --file --set=root /boot/kernel.xz
set default=0
set timeout=10
set timeout_style=menu
set linux=linux
set initrd=initrd

source (\${root})/boot/grub2/harvester.cfg

if [ "\${grub_cpu}" = "x86_64" -o "\${grub_cpu}" = "i386" ];then
    if [ "\${grub_platform}" = "efi" ]; then
        set linux=linuxefi
        set initrd=initrdefi
    fi
fi
if [ "\${grub_platform}" = "efi" ]; then
    echo "Please press 't' to show the boot menu on this console"
fi
set font=(\$root)/boot/x86_64/loader/grub2/fonts/unicode.pf2
if [ -f \${font} ];then
    loadfont \${font}
fi
menuentry "Harvester Installer \${harvester_version} Install Binaries Only" --class os --unrestricted {
    echo Loading kernel...
    \$linux (\$root)/boot/kernel cdroot root=live:CDLABEL=COS_LIVE rd.live.dir=/ rd.live.squashimg=rootfs.squashfs console=tty1 rd.cos.disable net.ifnames=1 \${extra_iso_cmdline} harvester.scheme_version=1 harvester.install.skipchecks=true harvester.install.mode=install harvester.install.device=$disk_device harvester.install.automatic=true
    echo Loading initrd...
    \$initrd (\$root)/boot/initrd
}

menuentry "Harvester Installer \${harvester_version}" --class os --unrestricted {
    echo Loading kernel...
    \$linux (\$root)/boot/kernel cdroot root=live:CDLABEL=COS_LIVE rd.live.dir=/ rd.live.squashimg=rootfs.squashfs console=tty1 rd.cos.disable net.ifnames=1 \${extra_iso_cmdline}
    echo Loading initrd...
    \$initrd (\$root)/boot/initrd
}

menuentry "Harvester Installer \${harvester_version} (VGA 1024x768)" --class os --unrestricted {
    set gfxpayload=1024x768x24,1024x768
    echo Loading kernel...
    \$linux (\$root)/boot/kernel cdroot root=live:CDLABEL=COS_LIVE rd.live.dir=/ rd.live.squashimg=rootfs.squashfs console=tty1 rd.cos.disable net.ifnames=1 \${extra_iso_cmdline}
    echo Loading initrd...
    \$initrd (\$root)/boot/initrd
}

if [ "\${grub_platform}" = "efi" ]; then
    hiddenentry "Text mode" --hotkey "t" {
        set textmode=true
        terminal_output console
    }
fi
EOF
```

## Automate Harvester Configuration

Harvester can be configured via Elemental when the proper options are passed in at boot. This can also be done by modifying Kernel arguments, but again, that is not as clean.

Define variables required for Harvester:
```bash
ntp_servers="1.2.3.4"
coredns_advertised_ip=192.168.0.253
dns_nameservers="192.168.0.253"
vip=192.168.0.100
mgmt_interface="eno1"
host_ip=192.168.0.101
host_subnet=255.255.255.0
host_gateway=192.168.0.254
token=token4kpro
password=password1234
hostname=kpro
```

Define variables required for deployed infrastructure:
```bash
registry_ns=registry
```

Create a blank file, `meta-data`. This might be used down the road.
```bash
cat > meta-data << EOF
EOF
```

Create a file, `user-data`, with the below contents. This exmaple will automatically configure the host on first boot, start and populate a container registry, Zot, start ArgoCD, and finally create an application, Tetris, within ArgoCD. Settings will need to be updated to match host configuration and environment.

```bash
cat > user-data << EOF
#cloud-config
scheme_version: 1
token: $token
os:
  password: $password
  hostname: $hostname
  ntp_servers:
    $(for server in $ntp_servers; do
        echo "- $server"
    done)
  dns_nameserver:
    $(for server in $dns_nameservers; do
        echo "- $server"
    done)
install:
  automatic: true
  mode: create
  vip_mode: static
  vip: $vip
  management_interface:
    interfaces:
      $(for interface in $mgmt_interface; do
          echo "- name: $interface"
      done)
    default_route: true
    method: static
    ip: $host_ip
    subnet_mask: $host_subnet
    gateway: $host_gateway
    bond_options:
      mode: balance-tlb
      miimon: 100

runcmd:
- bash /usr/local/setup.sh >>/usr/local/log 2>&1

write_files:
- path: /usr/local/setup.sh
  content: |
    #!/bin/bash

    echo "Checking if setup has already been ran"
    if [ -e /usr/local/setup_complete ]; then
      echo "Setup has already ran. Exiting."
      exit
    fi
    
    echo "Creating Directories"
    mkdir -p /usr/local/cidata

    echo "Mounting Install ISO"
    mount -L cidata /usr/local/cidata

    echo "Copying Infrastructure Images to RKE2"
    mkdir -p /var/lib/rancher/rke2/agent/images; cp /usr/local/cidata/hauler/seeder.tar.zst /var/lib/rancher/rke2/agent/images/.

    echo "Checking if RKE2 already started"
    journalctl -u rke2-server | tail

    echo "Waiting for RKE2 to be ready"
    while ! systemctl is-active --quiet rke2-server; do sleep 10; done

    echo "Waiting for Harvester namespace to exist"
    while ! /var/lib/rancher/rke2/bin/kubectl --kubeconfig /etc/rancher/rke2/rke2.yaml get namespace harvester-system >/dev/null 2>&1; do
      sleep 3
    done
    
    echo "Waiting for Harvester pods to start"
    while ! /var/lib/rancher/rke2/bin/kubectl --kubeconfig /etc/rancher/rke2/rke2.yaml get pods -n harvester-system --no-headers | grep -q .; do
      sleep 3
    done

    echo "Waiting for Harvester to be ready"
    while /var/lib/rancher/rke2/bin/kubectl --kubeconfig /etc/rancher/rke2/rke2.yaml get pods -n harvester-system -o jsonpath='{.items[*].status.containerStatuses[*].ready}' | grep "false" >/dev/null 2>&1; do
      sleep 3
    done

    sleep 10

    echo "Making sure Harvester Settings are available"
    while ! /var/lib/rancher/rke2/bin/kubectl --kubeconfig /etc/rancher/rke2/rke2.yaml get settings additional-ca; do
      sleep 3
    done

    echo "Configuring DNS"
    /var/lib/rancher/rke2/bin/kubectl --kubeconfig /etc/rancher/rke2/rke2.yaml apply -f /usr/local/manifests/coredns.yaml
    #/var/lib/rancher/rke2/bin/kubectl --kubeconfig /etc/rancher/rke2/rke2.yaml delete pod -l k8s-app=kube-dns -n kube-system

    echo "Copying Hauler to local PATH"
    mkdir -p /usr/local/bin
    cp /usr/local/cidata/hauler/hauler /usr/local/bin/hauler
    
    echo "Loading Helm Charts"
    /usr/local/bin/hauler store load -s /usr/local/seeder_files /usr/local/cidata/hauler/seeder_files.tar.zst
    /usr/local/bin/hauler store extract -s /usr/local/seeder_files hauler/registry.tgz:latest -o /usr/local/helm_charts
    /usr/local/bin/hauler store extract -s /usr/local/seeder_files hauler/cert-manager.tgz:latest -o /usr/local/helm_charts

    echo "Install Cert-Manager"
    XDG_CACHE_HOME=/usr/local/helm/.cache /usr/bin/helm --kubeconfig /etc/rancher/rke2/rke2.yaml upgrade --install cert-manager /usr/local/helm_charts/cert-manager.tgz --namespace cert-manager --create-namespace --set crds.enabled=true --set crds.keep=true

    echo "Waiting for Cert-Manager pod to be created"
    while ! /var/lib/rancher/rke2/bin/kubectl --kubeconfig /etc/rancher/rke2/rke2.yaml get pods -n cert-manager --no-headers | grep -q .; do
      sleep 3
    done

    echo "Waiting for Cert-Manager to be ready"
    while /var/lib/rancher/rke2/bin/kubectl --kubeconfig /etc/rancher/rke2/rke2.yaml get pods -n cert-manager -o jsonpath='{.items[*].status.containerStatuses[*].ready}' | grep "false" >/dev/null; do
      sleep 3
    done

    echo "Creating Cert-Manager Cluster Issuer"
    /var/lib/rancher/rke2/bin/kubectl --kubeconfig /etc/rancher/rke2/rke2.yaml apply -f /usr/local/manifests/cert-manager.yaml

    echo "Waiting for Cluster Issuer to be Ready"
    while ! /var/lib/rancher/rke2/bin/kubectl --kubeconfig /etc/rancher/rke2/rke2.yaml get clusterissuer | grep ca-cluster-issuer | grep True >/dev/null; do
      sleep 3
    done

    echo "Applying CA to Harvester"
    ca_crt=\`/var/lib/rancher/rke2/bin/kubectl --kubeconfig /etc/rancher/rke2/rke2.yaml get secret -n cert-manager root-ca-secret -o jsonpath="{.data.ca\.crt}" | base64 -d | sed 's/^/  /g'\`
    printf "apiVersion: harvesterhci.io/v1beta1\nkind: Setting\nmetadata:\n  name: additional-ca\nvalue: |-\n%s" "\$ca_crt" > /usr/local/manifests/harvester_additional_ca_settings.yaml
    /var/lib/rancher/rke2/bin/kubectl --kubeconfig /etc/rancher/rke2/rke2.yaml patch setting additional-ca --type=merge --patch-file /usr/local/manifests/harvester_additional_ca_settings.yaml

    echo "CA Settings applied at" `date`

    echo "Installing Registry"
    XDG_CACHE_HOME=/usr/local/helm/.cache /usr/bin/helm --kubeconfig /etc/rancher/rke2/rke2.yaml upgrade --install registry /usr/local/helm_charts/registry.tgz --namespace $registry_ns --create-namespace --values /usr/local/manifests/registry_values.yaml

    echo "Waiting for Registry pod to be created"
    while ! /var/lib/rancher/rke2/bin/kubectl --kubeconfig /etc/rancher/rke2/rke2.yaml get pods -n $registry_ns --no-headers | grep -q .; do
      sleep 3
    done

    echo "Waiting for Registry to be ready"
    while /var/lib/rancher/rke2/bin/kubectl --kubeconfig /etc/rancher/rke2/rke2.yaml get pods -n $registry_ns -o jsonpath='{.items[*].status.containerStatuses[*].ready}' | grep "false" >/dev/null; do
      sleep 3
    done

    echo "Making sure Registry is accessible"
    while ! curl -s https://registry.dap.sys/v2/_catalog | grep -q repositories; do
      sleep 3
    done

    echo "Loading Haul"
    /usr/local/bin/hauler store load -s /usr/local/registry /usr/local/cidata/hauler/collection.tar.zst 

    echo "Copying Haul to Registry"
    /usr/local/bin/hauler store copy -s /usr/local/registry registry://registry.dap.sys

    echo "Installing ArgoCD"
    XDG_CACHE_HOME=/usr/local/helm/.cache /usr/bin/helm --kubeconfig /etc/rancher/rke2/rke2.yaml upgrade --install argocd oci://registry.dap.sys/hauler/argo-cd --namespace argocd --create-namespace --values /usr/local/manifests/argocd_values.yaml

    echo "Waiting for ArgoCD namespace to exist"
    while ! /var/lib/rancher/rke2/bin/kubectl --kubeconfig /etc/rancher/rke2/rke2.yaml get namespace argocd >/dev/null 2>&1; do
      sleep 3
    done
    
    echo "Waiting for ArgoCD pods to start"
    while ! /var/lib/rancher/rke2/bin/kubectl --kubeconfig /etc/rancher/rke2/rke2.yaml get pods -n argocd --no-headers | grep -q .; do
      sleep 3
    done

    echo "Waiting for ArgoCD to be ready"
    while /var/lib/rancher/rke2/bin/kubectl --kubeconfig /etc/rancher/rke2/rke2.yaml get pods -n argocd -o jsonpath='{.items[*].status.containerStatuses[*].ready}' | grep "false" >/dev/null 2>&1; do
      sleep 3
    done

    echo "Configuring ArgoCD"
    /var/lib/rancher/rke2/bin/kubectl --kubeconfig /etc/rancher/rke2/rke2.yaml apply -f /usr/local/manifests/argocd_config.yaml

    echo "Install Webserver"
    /var/lib/rancher/rke2/bin/kubectl --kubeconfig /etc/rancher/rke2/rke2.yaml apply -f /usr/local/manifests/webserver.yaml

    echo "Waiting for Webserver namespace to exist"
    while ! /var/lib/rancher/rke2/bin/kubectl --kubeconfig /etc/rancher/rke2/rke2.yaml get namespace webserver >/dev/null 2>&1; do
      sleep 3
    done
    
    echo "Waiting for Webserver pods to start"
    while ! /var/lib/rancher/rke2/bin/kubectl --kubeconfig /etc/rancher/rke2/rke2.yaml get pods -n webserver --no-headers | grep -q .; do
      sleep 3
    done

    echo "Waiting for Webserver to be ready"
    while /var/lib/rancher/rke2/bin/kubectl --kubeconfig /etc/rancher/rke2/rke2.yaml get pods -n webserver -o jsonpath='{.items[*].status.containerStatuses[*].ready}' | grep "false" >/dev/null 2>&1; do
      sleep 3
    done

    echo "Extract x11docker"
    /usr/local/bin/hauler store extract -s /usr/local/registry hauler/x11docker:latest -o /usr/local/bin; chmod +x /usr/local/bin/x11docker

    # echo "Pull x11docker/xserver images from registry"
    # /usr/bin/nerdctl -a /run/k3s/containerd/containerd.sock pull registry.dap.sys/x11docker/xserver

    # echo "Retag x11docker/xserver"
    # /usr/bin/nerdctl -a /run/k3s/containerd/containerd.sock tag registry.dap.sys/x11docker/xserver x11docker/xserver 

    # echo "Load kpro/xfce"
    # /usr/bin/nerdctl -a /run/k3s/containerd/containerd.sock load < /usr/local/cidata/xfce.tar

    # echo "Run x11docker"
    # read Xenv < <(/usr/local/bin/x11docker --backend=nerdctl -I -i --home --vt=6 --cap-default --desktop --network=host --showenv kpro/xfce)

    echo "Push kpro/xfce to registry"
    /usr/bin/nerdctl -a /run/k3s/containerd/containerd.sock load < /usr/local/cidata/xfce.tar
    /usr/bin/nerdctl -a /run/k3s/containerd/containerd.sock tag kpro/xfce registry.dap.sys/kpro/xfce
    /usr/bin/nerdctl -a /run/k3s/containerd/containerd.sock push registry.dap.sys/kpro/xfce

    echo "Waiting for Harvester Settings to be Available"
    while ! /var/lib/rancher/rke2/bin/kubectl --kubeconfig /etc/rancher/rke2/rke2.yaml get setting additional-ca --no-headers | grep -q .; do
      sleep 3
    done

    echo "Unmounting Install ISO"
    umount /usr/local/cidata

    echo "Install completed on" \`date\`  > /usr/local/setup_complete

- content: |-
    service:
      type: ClusterIP
    ingress:
      annotations:
        cert-manager.io/cluster-issuer: ca-cluster-issuer
      enabled: true
      hosts:
        - host: registry.dap.sys
          paths:
            - path: /
      tls:
        - secretName: registry-tls
          hosts:
            - registry.dap.sys
    persistence: true
    pvc:
      create: true
      accessMode: "ReadWriteMany"
      storage: 8Gi
  owner: root:root
  path: /usr/local/manifests/registry_values.yaml
  permissions: '0644'

- content: |-
    global:
      domain: argo.dap.sys
      image:
        repository: registry.dap.sys/argoproj/argocd
    dex:
      image:
        repository: registry.dap.sys/dexidp/dex
    redis:
      image:
        repository: registry.dap.sys/docker/library/redis
    server:
      ingress:
        enabled: true
        ingressClassName: nginx
        annotations:
          cert-manager.io/cluster-issuer: ca-cluster-issuer
          nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
          nginx.ingress.kubernetes.io/backend-protocol: "HTTP"
        extraTls:
          - hosts:
            - argo.dap.sys
            secretName: argocd.dap.sys
    configs:
      params:
        server.insecure: "true"
      secret:
        argocdServerAdminPassword: \$2a\$12\$5439Sk/emkBi6XJwY.x7wuAm2xYjQa371YYvfMRMJcaVoMvOXMenq #password1234
  owner: root:root
  path: /usr/local/manifests/argocd_values.yaml
  permissions: '0644'

- content: |-
    apiVersion: v1
    data:
      enableOCI: dHJ1ZQ==
      insecure: dHJ1ZQ==
      name: dGVzdA==
      project: ZGVmYXVsdA==
      type: aGVsbQ==
      url: cmVnaXN0cnkuMTAuNy4yLjIzMC5uaXAuaW8vaGF1bGVy
    kind: Secret
    metadata:
      name: registry
      namespace: argocd
      annotations:
          managed-by: argocd.argoproj.io
      labels:
        argocd.argoproj.io/secret-type: repository
    type: Opaque
    ---
    apiVersion: argoproj.io/v1alpha1
    kind: Application
    metadata:
      name: tetris
      namespace: argocd
    spec:
      destination:
        namespace: tetris
        server: https://kubernetes.default.svc
      project: default
      source:
        chart: tetris
        helm:
          parameters:
          - name: ingress.hosts[0].host
            value: tetris.dap.sys
          - name: ingress.hosts[0].paths[0].path
            value: /
          - name: ingress.hosts[0].paths[0].pathType
            value: ImplementationSpecific
          - name: image.repository
            value: registry.dap.sys/boomstack/tetris
        repoURL: registry.dap.sys/hauler
        targetRevision: 0.1.9
      syncPolicy:
        syncOptions:
        - CreateNamespace=true
  owner: root:root
  path: /usr/local/manifests/argocd_config.yaml
  permissions: '0644'

- content: |-
    apiVersion: helm.cattle.io/v1
    kind: HelmChartConfig
    metadata:
      name: rke2-coredns
      namespace: kube-system
    spec:
      valuesContent: |
        nodelocal:
          enabled: true
        resources:
          limits:
            cpu: 1
            memory: 3Gi
          requests:
            cpu: 500m
            memory: 2Gi
        servers:
        - zones:
          - zone: .
          port: 53
          plugins:
          - name: errors
          - name: health
            configBlock: |-
              lameduck 5s
          - name: ready
          - name: kubernetes
            parameters: cluster.local in-addr.arpa ip6.arpa
            configBlock: |-
              pods insecure
              ttl 30
          - name: prometheus
            parameters: 0.0.0.0:9153
          - name: forward
            parameters: . /etc/resolv.conf
          - name: cache
            parameters: 30
          - name: loop
          - name: reload
          - name: loadbalance

        - zones:
          - zone: dap.sys
          port: 53  
          plugins:
          - name: errors
          - name: file
            parameters: /etc/coredns/zones/dap.zone dap.sys
          - name: log
          - name: cache

        extraVolumes:
          - name: custom-zonefile
            configMap:
              name: custom-zonefile-configmap
        extraVolumeMounts:
          - name: custom-zonefile
            mountPath: /etc/coredns/zones
    ---
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: custom-zonefile-configmap
      namespace: kube-system
    data:
      dap.zone: |
        \$ORIGIN dap.sys.
        \$TTL 3600
        @    IN  SOA ns1.dap.sys. admin.dap.sys. (
                  2024100201 ; serial
                  7200       ; refresh (2 hours)
                  3600       ; retry (1 hour)
                  1209600    ; expire (2 weeks)
                  3600       ; minimum (1 hour)
              )
            IN  NS   ns1.dap.sys.
        ns1         IN  A    $coredns_advertised_ip
        registry    IN  A    $vip 
        argo        IN  A    $vip
        tetris      IN  A    $vip
    ---
    apiVersion: v1
    kind: Service
    metadata:
      name: rke2-coredns-external
      namespace: kube-system
    spec:
      ports:
      - name: udp-53
        port: 53
        protocol: UDP
        targetPort: 53
      - name: tcp-53
        port: 53
        protocol: TCP
        targetPort: 53
      selector:
        app.kubernetes.io/instance: rke2-coredns
        app.kubernetes.io/name: rke2-coredns
        k8s-app: kube-dns
      sessionAffinity: None
      type: LoadBalancer
      loadBalancerIP: $coredns_advertised_ip # You define this IP to be your DNS IP for external servers (like VMs)
  owner: root:root
  path: /usr/local/manifests/coredns.yaml
  permissions: '0644'

- content: |-
    apiVersion: cert-manager.io/v1
    kind: Issuer
    metadata:
      name: selfsigned-issuer
      namespace: cert-manager
    spec:
      selfSigned: {}
    ---
    apiVersion: cert-manager.io/v1
    kind: Certificate
    metadata:
      name: selfsigned-ca
      namespace: cert-manager
    spec:
      isCA: true
      commonName: selfsigned-root-ca
      secretName: root-ca-secret
      duration: 52596h
      renewBefore: 43830h
      privateKey:
        algorithm: ECDSA
        size: 256
      issuerRef:
        name: selfsigned-issuer
        kind: Issuer
        group: cert-manager.io
    ---
    apiVersion: cert-manager.io/v1
    kind: ClusterIssuer
    metadata:
      name: ca-cluster-issuer
    spec:
      ca:
        secretName: root-ca-secret
  owner: root:root
  path: /usr/local/manifests/cert-manager.yaml
  permissions: '0644'

- content: |-
    apiVersion: v1
    kind: Namespace
    metadata:
      name: webserver
    ---
    apiVersion: v1
    kind: PersistentVolumeClaim
    metadata:
      name: webserver
      namespace: webserver
    spec:
      accessModes:
        - ReadWriteOnce
      resources:
        requests:
          storage: 5Gi  # Same size as the PV
    ---
    apiVersion: v1
    kind: ConfigMap
    metadata:
      name: webserver-config
      namespace: webserver
    data:
      nginx.conf: |
        user nginx;
        worker_processes 1;
        events {
          worker_connections  10240;
        }
        http {
          server {
              listen 80;
              server_name localhost;

              location / {
                root /usr/share/nginx/html;
                autoindex on;
                autoindex_exact_size off;
                autoindex_localtime on;
            }
          }
        }
    ---
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: webserver
      namespace: webserver
    spec:
      replicas: 1
      selector:
        matchLabels:
          app: webserver
      template:
        metadata:
          labels:
            app: webserver
        spec:
          containers:
          - name: webserver
            image: registry.dap.sys/library/nginx:1.27.3
            volumeMounts:
            - name: webserver-configmap
              mountPath: /etc/nginx/nginx.conf  # Mount custom nginx.conf here
              subPath: nginx.conf
            - name: webserver-volume
              mountPath: /usr/share/nginx/html  # Mount the PVC here for file storage
          volumes:
          volumes:
          - name: webserver-volume
            persistentVolumeClaim:
              claimName: webserver  # Mount the PVC
          - name: webserver-configmap
            configMap:
              name: webserver-config  # Reference the ConfigMap containing nginx.conf
    ---
    apiVersion: v1
    kind: Service
    metadata:
      name: webserver
      namespace: webserver
    spec:
      selector:
        app: webserver
      ports:
        - protocol: TCP
          port: 80  # Expose Nginx on port 80
          targetPort: 80  # Nginx container port
      type: LoadBalancer  # Use NodePort for local clusters
      loadBalancerIP: 192.168.0.253
    ---
    apiVersion: networking.k8s.io/v1
    kind: Ingress
    metadata:
      name: webserver
      namespace: webserver
      annotations:
        cert-manager.io/cluster-issuer: ca-cluster-issuer
        nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
        nginx.ingress.kubernetes.io/backend-protocol: "HTTP"
    spec:
      rules:
        - host: webserver.dap.sys
          http:
            paths:
              - path: /
                pathType: Prefix
                backend:
                  service:
                    name: webserver
                    port:
                      number: 80  # Expose the Nginx container via HTTP
      tls:
        - hosts:
            - webserver.dap.sys
          secretName: webserver-tls-secret  # The secret where the TLS certificate will be stored
  owner: root:root
  path: /usr/local/manifests/webserver.yaml
  permissions: '0644'

- content: |-
    /usr/bin/nerdctl -a /run/k3s/containerd/containerd.sock pull registry.dap.sys/x11docker/xserver
    /usr/bin/nerdctl -a /run/k3s/containerd/containerd.sock tag registry.dap.sys/x11docker/xserver x11docker/xserver

    /usr/bin/nerdctl -a /run/k3s/containerd/containerd.sock pull registry.dap.sys/kpro/xfce
    /usr/bin/nerdctl -a /run/k3s/containerd/containerd.sock tag registry.dap.sys/kpro/xfce kpro/xfce

    CONTAINERD_ADDRESS=/run/k3s/containerd/containerd.sock /usr/local/bin/x11docker --backend=nerdctl -I -i --home --vt=6 --cap-default --desktop --network=host --showenv kpro/xfce
  owner: root:root
  path: /usr/local/bin/desktop
  permissions: '0777'
EOF
```

## Download and Extract Harvester ISO

In order to rebuild Harvester, we have to first gather the Harvester ISO. Since we're rebuilding Harvester, we also need some of the files within the ISO to make it bootable again.

Download the ISO and extract the contents to a known location.

If you are on Mac, and since Apple makes Linux difficult, double click on the ISO in Finder. Ignore the error as opposed to Ejecting the volume when told the the disk is not readable. Use Disk Utility to find out to path to the 'disk', for example, /dev/disk2. In a terminal windows:

```bash
mkdir harvester_extracted
cd harvester_extracted
isoinfo -R -X -i ../< ISO_name >.iso
```

## Binary Dependencies

The repositories included Dockerfile has all of the commands the following steps wiil run already installed. This is optional as you may already have these binaries installed on your host.

Build harvester-automation container:
```bash
docker build -t harvester-automation .
```

Run harvester-automation container:
```bash
docker run -it -v $(pwd):/working harvester-automation
```

## Gather Hauler Bundles

Create a Hauler store
- seeder_files is separate as seeder (seeder_images) will be loaded into RKE2
```bash
hauler store sync -f hauler/seeder_images.yaml -s hauler/seeder
hauler store sync -f hauler/seeder_files.yaml -s hauler/seeder_files
hauler store sync -f hauler/collection.yaml -s hauler/collection
```

Save Hauler store
```bash
hauler store save --filename seeder.tar.zst -s hauler/seeder
hauler store save --filename seeder_files.tar.zst -s hauler/seeder_files
hauler store save --filename collection.tar.zst -s hauler/collection
```

## Next Steps

To create an appliance model where you install and configure Harvester via two separate ISOs, follow the instructions [here](dual_iso.md)

To create an automated ISO that will install and configure Harvester, follow the instructions [here](single_iso.md)
