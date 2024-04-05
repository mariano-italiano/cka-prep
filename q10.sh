
sudo systemctl stop kubelet; sudo sed -i 's|/usr/bin/kubelet|/usr/local/bin/kubelet|' /etc/systemd/system/kubelet.service.d/10-kubeadm.conf; sudo systemctl daemon-reload
