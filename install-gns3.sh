#! /bin/bash

echo "Removing old GNS3 files"
sudo rm /lib/systemd/system/gns3.service
sudo -r rm $HOME/GNS3
sudo userdel -rf gns3
echo "Removing GNS3 Installation"
sudo apt-get remove -y gns3-gui > /dev/null
sudo apt-get remove -y gns3-iou > /dev/null

echo "Adding GNS3 Repository"
sudo add-apt-repository -y ppa:gns3/ppa > /dev/null

echo "Updating Linux Repository"
sudo apt-get -y update > /dev/null

echo "Upgrading Linux Packages, that might take few minutes"
sudo apt-get -y upgrade > /dev/null

echo "Installing GNS3 Dependencies, that might take few minutes" 
sudo apt-get install -y apt-transport-https > /dev/null
sudo apt-get install -y ca-certificates > /dev/null
sudo apt-get install -y curl > /dev/null
sudo apt-get install -y software-properties-common > /dev/null
sudo apt-get install -y qemu qemu-kvm qemu-utils > /dev/null

sudo apt-get remove docker docker-engine docker.io > /dev/null
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" > /dev/null
sudo apt-get install -y docker-ce > /dev/null

echo "Installing GNS3"
sudo apt-get install -y gns3-gui > /dev/null
sudo dpkg --add-architecture i386 > /dev/null
sudo apt-get install -y gns3-iou > /dev/null

echo "Generating gns3 account, please enter password. This will be used to access GNS3"
sudo useradd -G kvm,ubridge,wireshark,docker,libvirtd,libvirt-qemu -m gns3
sudo passwd gns3

echo "Running GNS3 as Linux demon"
(sudo touch /lib/systemd/system/gns3.service)
echo "[Unit]
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
WantedBy=multi-user.target " | sudo tee /lib/systemd/system/gns3.service > /dev/null

sudo chmod 755 /lib/systemd/system/gns3.service
sudo systemctl daemon-reload

echo "Starting GNS3 demon at Linux boot"
sudo systemctl enable gns3.service

echo "Please Reboot to complete installation ...!!!"

