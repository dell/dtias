#!/bin/bash
# create configs needed for custom install

# source vars file
. ./variables

## create Grub CFG

cat > grub.cfg << EOF
search --no-floppy --file --set=root /boot/kernel.xz
set default=0
set timeout=6
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
menuentry "Harvester Installer \${harvester_version} - Automated Installer" --class os --unrestricted {
    echo Loading kernel...
    \$linux (\$root)/boot/kernel cdroot root=live:CDLABEL=$volume_id rd.live.dir=/ rd.live.squashimg=rootfs.squashfs console=tty1 rd.cos.disable net.ifnames=1 \${extra_iso_cmdline} harvester.scheme_version=1 harvester.install.skipchecks=true harvester.install.mode=install harvester.install.device=$os_disk_device harvester.install.data_disk=$data_disk_device harvester.install.automatic=true
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

## create meta-data file
touch meta-data

## Create user-data file
#  This exmaple will automatically configure the host on first boot, start and populate a container registry, Zot, start ArgoCD, and finally create an application, Tetris, within ArgoCD

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
    ##GITVERSION

    echo "Checking if setup has already been run"
    if [ -e /usr/local/setup_complete ]; then
      echo "Setup has already run. Exiting."
      exit
    fi
    
    echo "Creating Directories"
    mkdir -p /usr/local/cidata

    echo "Mounting Install ISO"
    mount -L $volume_id /usr/local/cidata

    echo "Copying Infrastructure Images to RKE2"
    mkdir -p /var/lib/rancher/rke2/agent/images; cp /usr/local/cidata/hauler/seeder.tar.zst /var/lib/rancher/rke2/agent/images/

    echo -n "Waiting for RKE2 to be ready"
    while ! systemctl is-active --quiet rke2-server; do sleep 10; echo -n . ; done
    echo

    echo -n "Waiting for Harvester namespace to exist"
    while ! /var/lib/rancher/rke2/bin/kubectl --kubeconfig /etc/rancher/rke2/rke2.yaml get namespace harvester-system >/dev/null 2>&1; do
      sleep 3 ; echo -n .
    done
    echo
    
    echo -n "Waiting for Harvester pods to start"
    while ! /var/lib/rancher/rke2/bin/kubectl --kubeconfig /etc/rancher/rke2/rke2.yaml get pods -n harvester-system --no-headers 2>&1 | grep -q .; do
      sleep 3 ; echo -n .
    done
    echo

    echo -n "Waiting for Harvester to be ready"
    while /var/lib/rancher/rke2/bin/kubectl --kubeconfig /etc/rancher/rke2/rke2.yaml get pods -n harvester-system -o jsonpath='{.items[*].status.containerStatuses[*].ready}' | grep "false" >/dev/null 2>&1; do
      sleep 3 ; echo -n .
    done
    echo

    sleep 10

    echo -n "Making sure Harvester is ready"
    while /var/lib/rancher/rke2/bin/kubectl --kubeconfig /etc/rancher/rke2/rke2.yaml get pods -n harvester-system -o jsonpath='{.items[*].status.containerStatuses[*].ready}' | grep "false" >/dev/null 2>&1; do
      sleep 3 ; echo -n .
    done
    echo

    echo "Configuring DNS"
    /var/lib/rancher/rke2/bin/kubectl --kubeconfig /etc/rancher/rke2/rke2.yaml apply -f /usr/local/manifests/coredns.yaml

    echo "Copying Hauler to local PATH"
    mkdir -p /usr/local/bin
    cp /usr/local/cidata/hauler/hauler /usr/local/bin/hauler
    
    echo "Loading Helm Charts"
    /usr/local/bin/hauler store load -s /usr/local/seeder_files /usr/local/cidata/hauler/seeder_files.tar.zst
    /usr/local/bin/hauler store extract -s /usr/local/seeder_files hauler/registry.tgz:latest -o /usr/local/helm_charts
    /usr/local/bin/hauler store extract -s /usr/local/seeder_files hauler/cert-manager.tgz:latest -o /usr/local/helm_charts

    echo "Install Cert-Manager"
    XDG_CACHE_HOME=/usr/local/helm/.cache /usr/bin/helm --kubeconfig /etc/rancher/rke2/rke2.yaml upgrade --install cert-manager /usr/local/helm_charts/cert-manager.tgz --namespace cert-manager --create-namespace --set crds.enabled=true --set crds.keep=true >/dev/null

    echo -n "Waiting for Cert-Manager to be ready"
    while ! /var/lib/rancher/rke2/bin/kubectl --kubeconfig /etc/rancher/rke2/rke2.yaml get pods -n cert-manager -o jsonpath='{.items[*].status.containerStatuses[*].ready}' | grep -q "true true true"; do
      sleep 3 ; echo -n .
    done
    echo

    echo "Creating Cert-Manager Cluster Issuer"
    /var/lib/rancher/rke2/bin/kubectl --kubeconfig /etc/rancher/rke2/rke2.yaml apply -f /usr/local/manifests/cert-manager.yaml

    echo "Loading Collections Haul"
    /usr/local/bin/hauler store load -s /usr/local/registry /usr/local/cidata/hauler/collection.tar.zst >/dev/null

    echo "Load kpro/xfce"
    /usr/local/bin/hauler store load -s /usr/local/registry /usr/local/cidata/xfce.tar >/dev/null

    echo -n "Waiting for Cluster Issuer to be Ready"
    while ! /var/lib/rancher/rke2/bin/kubectl --kubeconfig /etc/rancher/rke2/rke2.yaml get clusterissuer | grep ca-cluster-issuer | grep True >/dev/null; do
      sleep 3 ; echo -n .
    done
    echo

    echo -n "Waiting for CA Cert to be Ready"
    while ! /var/lib/rancher/rke2/bin/kubectl --kubeconfig /etc/rancher/rke2/rke2.yaml get secret -n cert-manager root-ca-secret -o jsonpath='{.data.ca\.crt}' 2>&1 | base64 -d | grep END 2>&1 >/dev/null; do
      sleep 3 ; echo -n .
    done
    echo

    echo -n "Making sure Harvester Settings are available"
    while ! /var/lib/rancher/rke2/bin/kubectl --kubeconfig /etc/rancher/rke2/rke2.yaml get settings additional-ca 2>&1 >/dev/null; do
      sleep 3 ; echo -n .
    done
    echo

    echo "Installing Root CA from Cert-Manager"
    ca_crt=\`/var/lib/rancher/rke2/bin/kubectl --kubeconfig /etc/rancher/rke2/rke2.yaml get secret -n cert-manager root-ca-secret -o jsonpath="{.data.ca\.crt}" | base64 -d | sed 's/^/  /g'\`
    printf "apiVersion: harvesterhci.io/v1beta1\nkind: Setting\nmetadata:\n  name: additional-ca\nvalue: |-\n%s" "\$ca_crt" > /usr/local/manifests/harvester_additional_ca_settings.yaml
    /var/lib/rancher/rke2/bin/kubectl --kubeconfig /etc/rancher/rke2/rke2.yaml patch setting additional-ca --type=merge --patch-file /usr/local/manifests/harvester_additional_ca_settings.yaml 2>&1 > /dev/null

    echo -n "Waiting for CA Settings to be Available"
    while ! /var/lib/rancher/rke2/bin/kubectl --kubeconfig /etc/rancher/rke2/rke2.yaml get setting additional-ca -o jsonpath='{.value}' 2>&1 | grep END 2>&1 >/dev/null; do
      sleep 3 ; echo -n .
    done
    echo

    echo "Installing Registry"
    XDG_CACHE_HOME=/usr/local/helm/.cache /usr/bin/helm --kubeconfig /etc/rancher/rke2/rke2.yaml upgrade --install registry /usr/local/helm_charts/registry.tgz --namespace $registry_ns --create-namespace --values /usr/local/manifests/registry_values.yaml >/dev/null

    echo -n "Waiting for Registry pod to be created"
    while ! /var/lib/rancher/rke2/bin/kubectl --kubeconfig /etc/rancher/rke2/rke2.yaml get pods -n $registry_ns --no-headers | grep -q .; do
      sleep 3 ; echo -n .
    done
    echo

    echo -n "Waiting for Registry to be ready"
    while /var/lib/rancher/rke2/bin/kubectl --kubeconfig /etc/rancher/rke2/rke2.yaml get pods -n $registry_ns -o jsonpath='{.items[*].status.containerStatuses[*].ready}' | grep "false" >/dev/null; do
      sleep 3 ; echo -n .
    done
    echo

    echo -n "Making sure Registry is accessible - install CA on host machine to ensure SSL connection"
    while ! curl -s https://registry.dap.sys/v2/_catalog | grep -q repositories 2>&1 >/dev/null; do
      /var/lib/rancher/rke2/bin/kubectl --kubeconfig /etc/rancher/rke2/rke2.yaml patch setting additional-ca --type=merge --patch-file /usr/local/manifests/harvester_additional_ca_settings.yaml 2>&1 > /dev/null
      sleep 3 ; echo -n .
    done
    echo
    
    echo -n "Installing ArgoCD"
    while ! XDG_CACHE_HOME=/usr/local/helm/.cache /usr/bin/helm --kubeconfig /etc/rancher/rke2/rke2.yaml upgrade --install argocd oci://registry.dap.sys/hauler/argo-cd --namespace argocd --create-namespace --values /usr/local/manifests/argocd_values.yaml 2>&1 >/dev/null
    do 
      sleep 3 ; echo -n .
    done
    echo

    echo -n "Waiting for ArgoCD namespace to exist"
    while ! /var/lib/rancher/rke2/bin/kubectl --kubeconfig /etc/rancher/rke2/rke2.yaml get namespace argocd >/dev/null 2>&1; do
      sleep 3 ; echo -n .
    done
    echo
    
    echo -n "Waiting for ArgoCD pods to start"
    while ! /var/lib/rancher/rke2/bin/kubectl --kubeconfig /etc/rancher/rke2/rke2.yaml get pods -n argocd --no-headers | grep -q .; do
      sleep 3 ; echo -n .
    done
    echo
    
    echo -n "Waiting for ArgoCD to be ready"
    while /var/lib/rancher/rke2/bin/kubectl --kubeconfig /etc/rancher/rke2/rke2.yaml get pods -n argocd -o jsonpath='{.items[*].status.containerStatuses[*].ready}' | grep "false" >/dev/null 2>&1; do
      sleep 3 ; echo -n .
    done
    echo

    echo "Configuring ArgoCD"
    /var/lib/rancher/rke2/bin/kubectl --kubeconfig /etc/rancher/rke2/rke2.yaml apply -f /usr/local/manifests/argocd_config.yaml

    echo "Install Webserver"
    /var/lib/rancher/rke2/bin/kubectl --kubeconfig /etc/rancher/rke2/rke2.yaml apply -f /usr/local/manifests/webserver.yaml

    echo -n "Waiting for Webserver namespace to exist"
    while ! /var/lib/rancher/rke2/bin/kubectl --kubeconfig /etc/rancher/rke2/rke2.yaml get namespace webserver >/dev/null 2>&1; do
      sleep 3; echo -n .
    done
    echo
    
    echo -n "Waiting for Webserver pods to start"
    while ! /var/lib/rancher/rke2/bin/kubectl --kubeconfig /etc/rancher/rke2/rke2.yaml get pods -n webserver --no-headers | grep -q .; do
      sleep 3; echo -n .
    done
    echo

    echo -n "Waiting for Webserver to be ready"
    while /var/lib/rancher/rke2/bin/kubectl --kubeconfig /etc/rancher/rke2/rke2.yaml get pods -n webserver -o jsonpath='{.items[*].status.containerStatuses[*].ready}' | grep "false" >/dev/null 2>&1; do
      sleep 3; echo -n .
    done
    echo
 
    echo -n "Synching Root CA to ArgoCD, and Starting Tetris"
    while ! /var/lib/rancher/rke2/bin/kubectl --kubeconfig /etc/rancher/rke2/rke2.yaml exec -n argocd \$ARGOCD_CONTAINER  -- argocd --insecure  --server argo.dap.sys app sync tetris 2>&1 > /dev/null ; do
      ARGOCD_CONTAINER=\$(/var/lib/rancher/rke2/bin/kubectl --kubeconfig /etc/rancher/rke2/rke2.yaml get pod -n argocd -l app.kubernetes.io/name=argocd-server -oname)
      /var/lib/rancher/rke2/bin/kubectl --kubeconfig /etc/rancher/rke2/rke2.yaml exec \$ARGOCD_CONTAINER -n argocd -- argocd --grpc-web --insecure  login argo.dap.sys --username admin --password $password 2>&1 > /dev/null
      /var/lib/rancher/rke2/bin/kubectl --kubeconfig /etc/rancher/rke2/rke2.yaml get secret -n cert-manager root-ca-secret -o jsonpath="{.data.ca\.crt}" | base64 -d |  \\
      /var/lib/rancher/rke2/bin/kubectl --kubeconfig /etc/rancher/rke2/rke2.yaml  exec -in argocd \$ARGOCD_CONTAINER  -- argocd --insecure --grpc-web --server argo.dap.sys cert add-tls registry.dap.sys 2>&1 > /dev/null
      sleep 5; echo -n .
    done
    echo

    echo "Extract x11docker"
    /usr/local/bin/hauler store extract -s /usr/local/registry hauler/x11docker:latest -o /usr/local/bin; chmod +x /usr/local/bin/x11docker

    echo "Load and retag kpro/xfce"
    /usr/bin/nerdctl -a /run/k3s/containerd/containerd.sock load < /usr/local/cidata/xfce.tar 2>&1 >/dev/null
    /usr/bin/nerdctl -a /run/k3s/containerd/containerd.sock tag kpro/xfce registry.dap.sys/kpro/xfce 2>&1 >/dev/null

    echo "Pull x11docker/xserver images from registry and retag"
    /usr/bin/nerdctl -a /run/k3s/containerd/containerd.sock pull registry.dap.sys/x11docker/xserver 2>&1 >/dev/null
    /usr/bin/nerdctl -a /run/k3s/containerd/containerd.sock tag registry.dap.sys/x11docker/xserver x11docker/xserver  2>&1 >/dev/null

    echo "Unmounting Install ISO"
    umount /usr/local/cidata

    echo "Install completed on" \`date\`  > /usr/local/setup_complete

    echo "Run x11docker with Firefox"
    chown -R rancher:rancher /home/rancher
    CONTAINERD_ADDRESS=/run/k3s/containerd/containerd.sock /usr/local/bin/desktop

- content: |-
    [Desktop Entry]
    Encoding=UTF-8
    Version=0.9.4
    Type=Application
    Name=Harvester Firefox
    Comment=
    Exec=firefox --new-tab https://harvester.dap.sys --new-tab --url https://tetris.dap.sys
    OnlyShowIn=XFCE;
    RunHook=0
    StartupNotify=false
    Terminal=false
    Hidden=false
  owner: rancher:rancher
  path: /home/rancher/.local/share/x11docker/kpro-xfce/.config/autostart/firefox.desktop
  permissions: '0644'
  
- content: |-
    hauler:
      image:
        repository: ghcr.io/hauler-dev/hauler
        tag: 1.1.1
      imagePullPolicy: IfNotPresent
      initContainers:
        image:
          repository: rancher/kubectl
          tag: v1.29.2 # update to your kubernetes version
        imagePullPolicy: IfNotPresent
        timeout: 1h
      data:
        pvc:
          accessModes: ReadWriteMany
          # storageClass: longhorn # optional... will use default storage class
          storageRequest: 8Gi # recommended size of 3x the artifact(s)
    haulerJobs:
      image:
        repository: ghcr.io/hauler-dev/hauler-debug
        tag: 1.1.1
      imagePullPolicy: IfNotPresent
      hauls:
        enabled: false
      manifests:
        enabled: false
      localhauls:
        enabled: true
        hostPath: /usr/local/registry
    haulerFileserver:
        enabled: false
    haulerRegistry:
      enabled: true
      port: 5000 # default port for the registry
      replicas: 1
      ingress:
        annotations:
          cert-manager.io/cluster-issuer: ca-cluster-issuer
          nginx.ingress.kubernetes.io/force-ssl-redirect: "true"
        enabled: true
        hostname: registry.dap.sys
        tls:
          enabled: true
          source: secret
          secretName: registry-tls
      service:
        enabled: true
        type: ClusterIP
        ports:
          protocol: TCP
          port: 5000 # default port for the registry
          targetPort: 5000 # default port for the registry
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
        argocdServerAdminPassword: $(htpasswd -bnBC 10  "" $password | tr -d ':\n' ; echo)
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
        webserver   IN  A    $vip
        harvester   IN  A    $vip
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
    CONTAINERD_ADDRESS=/run/k3s/containerd/containerd.sock
    nerdctl rm x11docker-firefox
    /usr/local/bin/x11docker --name=x11docker-firefox --backend=nerdctl -I -i --home --vt=1 --hostuser=rancher --cap-default --desktop --network=host kpro/xfce --ipc=host -- x-session-manager
  owner: root:root
  path: /usr/local/bin/desktop
  permissions: '0777'
EOF
