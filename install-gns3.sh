#! /bin/bash

echo ""
echo "Removing Old GNS3 Files"
echo "====================================="
sudo rm /lib/systemd/system/gns3.service
sudo rm -r $HOME/GNS3
sudo rm -r /var/log/gns3
sudo rm -r /var/run/gns3
sudo userdel -rf gns3

echo ""
echo "Removing Previous GNS3 Installation"
echo "====================================="
sudo apt-get remove -y gns3-server > /dev/null
sudo apt-get remove -y gns3-gui > /dev/null
sudo apt-get remove -y gns3-iou > /dev/null

echo ""
echo "Adding GNS3 Repository"
echo "====================================="
sudo add-apt-repository -y ppa:gns3/ppa > /dev/null

echo ""
echo "Updating Linux Repository"
echo "====================================="
sudo apt-get -y update > /dev/null

echo ""
echo "Upgrading Linux Packages, that might take few minutes"
echo "====================================="
sudo apt-get -y upgrade > /dev/null

echo ""
echo "Installing GNS3 Dependencies, that might take few minutes" 
echo "====================================="
sudo apt-get install -y apt-transport-https software-properties-common > /dev/null
sudo apt-get install -y curl ca-certificates > /dev/null
sudo apt-get install -y iouyap dynamips ubridge > /dev/null
sudo apt-get install -y qemu qemu-kvm qemu-utils > /dev/null
sudo apt-get install -y python python3 python-pip python-pip3 > /dev/null

sudo apt-get remove docker docker-engine docker.io > /dev/null
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
sudo add-apt-repository -y "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" > /dev/null
sudo apt-get install -y docker-ce > /dev/null

echo ""
echo "Installing GNS3"
echo "====================================="
sudo apt-get install -y gns3-server > /dev/null
sudo apt-get install -y gns3-gui > /dev/null
sudo dpkg --add-architecture i386 > /dev/null
sudo apt-get install -y gns3-iou > /dev/null

echo ""
echo "Generating user \"gns3\" account, please enter password. This will be used to access GNS3"
echo "====================================="
sudo useradd -G kvm,ubridge,wireshark,docker,libvirtd,libvirt-qemu -m gns3
sudo passwd gns3

echo ""
echo "Running GNS3 as Linux demon"
echo "====================================="
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

echo ""
echo "Starting GNS3 demon at Linux boot"
echo "====================================="
sudo systemctl enable gns3.service

echo ""
echo "Please reboot to complete installation ...!!!"
echo "====================================="

