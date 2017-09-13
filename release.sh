#!/bin/bash
#Require root to run this script
if [[ "$(whoami)" != "root" ]]; then
	echo -e "\033[31;40m Require root to run this script\033[0m" >&2
	exit 1
fi
ping -c 1 www.baidu.com >/dev/null
[ ! $? -eq 0 ] && echo $"Networking not configured - exiting" && exit 1

echo -e "\033[36;40m =====================清空旧的文件目录=====================\033[0m"
sudo remastersys clean
if [[ $? -eq 0 ]];then
    echo -e "\033[32;40m Successful removal of image file\033[0m"
else
    echo -e "\033[31;40m Failure removal of image file\033[0m"
fi
dpkg --purge openssh-server
dpkg --purge lrzsz
sudo rm -rf /home/Portal/*.iso && echo -e "\033[32;40m Remove the old image\033[0m"
sudo rm -rf /home/Portal/livecd
sudo umount /home/Portal/mnt
sudo rm -rf /home/Portal/mnt/

#################################################################################
echo -e "\033[36;40m =====================remastersys bacckup=====================\033[0m"
sudo remastersys backup
echo -e "\033[36;40m =====================remastersys bacckup successful=====================\033[0m"
sleep 5

if [ -d "/home/Portal/livecd" ]; then
    sudo rm -rf /home/Portal/livecd && sudo mkdir /home/Portal/livecd && echo -e "\033[32;40m Delete and create a new directory for livecd\033[0m"
else
    mkdir /home/Portal/livecd && echo -e "\033[32;40m Create directory for livecd\033[0m"
fi
sleep 5
#删除旧的mnt目录并创建新的mnt目录
sudo umount /home/Portal/mnt
if [ -d "/home/Portal/mnt" ]; then
    sudo rm -rf /home/Portal/mnt/ && sudo mkdir /home/Portal/mnt && echo -e "\033[32;40m Delete and create mnt directory\033[0m"
else
    sudo mkdir /home/Portal/mnt && echo -e "\033[32;40m mnt directory not found\n Create directory for mnt\033[0m"
fi
sleep 5

sudo mount -o loop /tmp/ubuntu-15.04-desktop-amd64.iso /home/Portal/mnt/
echo -e "\033[32;40m mount iso to mnt\n\033[0m"
sudo rsync --exclude=/home/Portal/mnt/casper/filesystem.squashfs -a /home/Portal/mnt/ /home/Portal/livecd/
echo -e "\033[32;40m rsync successful\n\033[0m"
sleep 5
sudo chmod o+w /home/Portal/livecd/casper/filesystem.*
echo -e "\033[32;40m Change the permissions successful\n\033[0m"
sleep 5
sudo cp /home/remastersys/remastersys/ISOTMP/casper/filesystem.* /home/Portal/livecd/casper/
echo -e "\033[32;40m Copy the file successful\n\033[0m"
sleep 5
sudo dpkg -l | grep ii | awk '{print $2,$3}' > /home/Portal/livecd/casper/filesystem.manifest
sudo dpkg -l | grep ii | awk '{print $2,$3}' > /home/Portal/livecd/casper/filesystem.manifest-desktop
echo -e "\033[32;40m update filesystem.manifest successful\n\033[0m"
sleep 5
sudo rm /home/Portal/livecd/md5sum.txt
cd /home/Portal/livecd/ && sudo find -type f -print0 | sudo xargs -0 md5sum | grep -v ./isolinux/ | grep -v ./md5sum.txt | sudo tee md5sum.txt
echo -e "\033[32;40m update md5sum successful\n\033[0m"
sleep 5
cd /home/Portal/livecd && sudo mkisofs -D -r -V "$IMAGE_NAME" -cache-inodes -J -l -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -allow-limited-size  -o ../ubuntu-portal-cd-`date '+%Y-%m-%d'`.iso .
ls /home/Portal |grep *.iso
sleep 5
sudo apt-get install -y openssh-server lrzsz >/dev/null

echo ""
echo -e "\E[1;32m===================================\E[0m"
echo -e "\E[1;32m新发布镜像为：/home/Portal/`ls /home/Portal/ |grep iso`\E[0m"
echo -e "\E[1;32m===================================\E[0m"
echo ""