#! /bin/bash

sudo pkill gns3
sudo rm -r /lib/systemd/system/gns3.service
sudo apt remove -y gns3-gui
sudo apt remove -y gns3-iou

sudo add-apt-repository -y ppa:gns3/ppa
sudo apt -y update
sudo apt -y upgrade
sudo apt install -y apt-transport-https
sudo apt install -y ca-certificates
sudo apt install -y curl
sudo apt install -y software-properties-common
sudo apt install -y qemu qemu-kvm qemu-utils

sudo apt-get remove docker docker-engine docker.io
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"
sudo apt install -y docker-ce

sudo apt install -y gns3-gui
sudo dpkg --add-architecture i386
sudo apt install -y gns3-iou

sudo useradd -G kvm,ubridge,wireshark,docker,libvirtd,libvirt-qemu -m gns3
sudo passwd gns3

(cd /lib/systemd/system && sudo touch gns3.service)

echo " [Unit]
Description=GNS3 server
Wants=network-online.target
After=network.target network-online.target

[Service]
Type=forking
User=gns3
Group=gns3
PermissionsStartOnly=true
ExecStartPre=/bin/mkdir -p /var/log/gns3 /var/run/gns3
ExecStartPre=/bin/chown -R gns3:gns3 /var/log/gns3 /var/run/gns3
ExecStart=/usr/share/gns3/gns3-server/bin/gns3server --log /var/log/gns3/gns3.log --pid /var/run/gns3/gns3.pid --daemon
Restart=on-abort
PIDFile=/var/run/gns3/gns3.pid

[Install]
WantedBy=multi-user.target " > gns3.service

sudo chmod 755 gns3.service
sudo systemctl daemon-reload
sudo systemctl enable gns3.service

echo "Please Reboot"

