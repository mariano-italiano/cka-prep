# CKA Advanced Practice Tasks – 5 per Domain

## 1. Cluster Architecture, Installation & Configuration (25%)

### Task 1: Configure External etcd for HA Cluster
**Scenario:**  
Set up a Kubernetes control plane node to use an existing external etcd cluster running at `10.0.0.10:2379`.  
Adjust kube-apiserver manifest accordingly.

**Solution:**
1. Edit `/etc/kubernetes/manifests/kube-apiserver.yaml`.
2. Add flags:
```bash
--etcd-servers=https://10.0.0.10:2379
--etcd-cafile=/etc/kubernetes/pki/etcd/ca.crt
--etcd-certfile=/etc/kubernetes/pki/apiserver-etcd-client.crt
--etcd-keyfile=/etc/kubernetes/pki/apiserver-etcd-client.key
```
3. Save file — kubelet will restart API server.

---

### Task 2: Restrict kubectl Access for a Group
**Scenario:**  
Create an RBAC policy so that members of the `viewers` group can list and get Pods in namespace `dev` but cannot edit or delete them.

**Solution:**
```bash
kubectl create role pod-view --verb=get,list --resource=pods -n dev
kubectl create rolebinding pod-view-binding --role=pod-view --group=viewers -n dev
```

---

### Task 3: Install a CNI Plugin with Custom MTU
**Scenario:**  
Deploy Calico with MTU set to `1400`.

**Solution:**
```bash
kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
kubectl set env daemonset/calico-node -n kube-system FELIX_MTUIface=eth0 FELIX_IPINIPMTU=1400
```

---

### Task 4: Create a Custom Resource and Operator
**Scenario:**  
Deploy a sample CRD for a `Backup` resource and create an instance of it.

**Solution:**
```bash
kubectl apply -f backup-crd.yaml
kubectl apply -f my-backup.yaml
```

---

### Task 5: Configure Audit Logging
**Scenario:**  
Enable Kubernetes audit logs and store them at `/var/log/k8s-audit.log`.

**Solution:**
- Add `--audit-log-path=/var/log/k8s-audit.log` and `--audit-policy-file=/etc/kubernetes/audit-policy.yaml` to kube-apiserver manifest.
- Restart API server via kubelet manifest change.

---

## 2. Workloads & Scheduling (15%)

### Task 1: Blue-Green Deployment
**Scenario:**  
Deploy two versions of an app (`v1` and `v2`) and switch traffic from v1 to v2 without downtime.

**Solution:**
- Create two Deployments: `app-v1` and `app-v2`.
- Update Service selector from `version=v1` to `version=v2`.

---

### Task 2: Node Affinity with Taints
**Scenario:**  
Run a Pod only on nodes labeled `env=prod` and tolerate a taint `critical=true:NoSchedule`.

**Solution:**
Pod spec:
```yaml
nodeAffinity:
  requiredDuringSchedulingIgnoredDuringExecution:
    nodeSelectorTerms:
    - matchExpressions:
      - key: env
        operator: In
        values:
        - prod
tolerations:
- key: "critical"
  operator: "Equal"
  value: "true"
  effect: "NoSchedule"
```

---

### Task 3: Init Container for Config Preparation
**Scenario:**  
Deploy an app Pod that downloads a config file before starting the main container.

**Solution:**
Use `initContainers` to `wget` the file into an `emptyDir` volume shared with the main container.

---

### Task 4: Horizontal Pod Autoscaler
**Scenario:**  
Scale a Deployment `api` between 2 and 6 replicas when CPU > 60%.

**Solution:**
```bash
kubectl autoscale deployment api --min=2 --max=6 --cpu-percent=60
```

---

### Task 5: Ephemeral Containers for Debug
**Scenario:**  
Attach an ephemeral container to a running Pod named `web` for troubleshooting.

**Solution:**
```bash
kubectl debug -it web --image=busybox --target=web
```

---

## 3. Services & Networking (20%)

### Task 1: Multi-Port Service
**Scenario:**  
Expose a Pod that has two containers (`api` on 8080 and `metrics` on 9090) via a single ClusterIP Service.

**Solution:**  
Service spec with two ports mapping to each containerPort.

---

### Task 2: Ingress with TLS
**Scenario:**  
Create an Ingress for host `app.example.com` using TLS secret `app-tls`.

**Solution:**  
Ingress YAML with `tls` block and `secretName: app-tls`.

---

### Task 3: Gateway API HTTPRoute
**Scenario:**  
Route `/v1` to service `api-v1` and `/v2` to `api-v2`.

**Solution:**  
Create `HTTPRoute` with two rules and path matches.

---

### Task 4: Egress Restriction
**Scenario:**  
Prevent Pods in `default` namespace from accessing the internet except `10.0.0.0/8`.

**Solution:**  
Egress NetworkPolicy with `to.cidr` allowing `10.0.0.0/8` only.

---

### Task 5: Debug Service Connectivity
**Scenario:**  
Service `frontend` cannot reach `backend`. Verify endpoints and fix.

**Solution:**
```bash
kubectl get endpoints backend
kubectl describe svc backend
# Update selector or redeploy pods if labels mismatch
```

---

## 4. Storage (10%)

### Task 1: Dynamic Provisioning
**Scenario:**  
Use default StorageClass to dynamically provision PVC `pvc-dyn` of 5Gi.

**Solution:**
```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: pvc-dyn
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi
  storageClassName: standard
```

---

### Task 2: StatefulSet with PVC Template
**Scenario:**  
Deploy StatefulSet `db` with each replica having its own 1Gi PVC.

**Solution:**  
StatefulSet spec with `volumeClaimTemplates`.

---

### Task 3: Bind PVC to Specific PV
**Scenario:**  
Manually bind PVC `manual-pvc` to PV `manual-pv`.

**Solution:**  
Set `spec.volumeName` in PVC manifest.

---

### Task 4: Resize PV
**Scenario:**  
Increase `pvc-dyn` from 5Gi to 10Gi.

**Solution:**  
Edit PVC, update `resources.requests.storage`, ensure SC supports expansion.

---

### Task 5: Change Reclaim Policy
**Scenario:**  
Change PV `pv-logs` reclaim policy from `Delete` to `Retain`.

**Solution:**
```bash
kubectl patch pv pv-logs -p '{"spec":{"persistentVolumeReclaimPolicy":"Retain"}}'
```

---

## 5. Troubleshooting (30%)

### Task 1: Node NotReady due to Kubelet
**Scenario:**  
Identify and fix kubelet misconfiguration on node `worker-1`.

**Solution:**  
Check `journalctl -u kubelet`, correct config in `/var/lib/kubelet/config.yaml`, restart kubelet.

---

### Task 2: Pod ImagePullBackOff
**Scenario:**  
Fix `web` Pod failing to pull image from private registry.

**Solution:**  
Create secret with `docker-registry` type, update Pod spec with `imagePullSecrets`.

---

### Task 3: Service Not Resolving DNS
**Scenario:**  
CoreDNS Pod crashlooping. Fix configuration.

**Solution:**  
Check logs, validate `ConfigMap coredns`, correct syntax, restart.

---

### Task 4: Control Plane Component Down
**Scenario:**  
`kube-controller-manager` Pod not running on master.

**Solution:**  
Check manifest in `/etc/kubernetes/manifests/kube-controller-manager.yaml` for errors.

---

### Task 5: NetworkPolicy Blocking Traffic
**Scenario:**  
Pods can't reach `api` service after policy applied.

**Solution:**  
Inspect applied NetworkPolicies, adjust ingress/egress rules to allow traffic.
