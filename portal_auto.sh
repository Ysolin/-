#!/usr/bin/env bash
BDYUN="/home/Portal/Portal_`date '+%Y-%m-%d'`/build_bdyun"
ZTE="/home/Portal/Portal_`date '+%Y-%m-%d'`/build_zte"
PORTAL=/home/Portal/Portal_`date '+%Y-%m-%d'`
RES='\E[0m'
RED_COLOR='\E[1;31m'
GREEN_COLOR='\E[1;32m'
BLUE_COLOR='\E[1;34m'
ip="192.168.119.84"
user="root"
cmd1="/tmp/portalbd_install.sh"
cmd2="/tmp/portalzte_install.sh"
cmd3=/tmp/release.sh
port='22'
Type=0
echo -e "${GREEN_COLOR}----------------------云平台自动化-----------------------${RES}"
#检查是否是Portal用户
if [[ "$(whoami)" != "Portal" ]]; then
	echo -e "\033[31;40m Require Portal to run this script\033[0m" >&2
	exit 1
fi

#检查网络是否通
ping -c 1 192.168.119.84 >/dev/null
[ ! $? -eq 0 ] && echo $"不能链接Git服务器！" && exit 1
echo /dev/null > /home/Portal/.ssh/known_hosts
scp /home/Portal/tools/* root@192.168.119.84:/tmp/

#克隆云平台代码
rm -rf /home/Portal/Portal*
echo -e "${GREEN_COLOR}========================================================${RES}"
echo -e "${GREEN_COLOR}开始克隆云平台代码${RES}"
cd /home/Portal/ && git clone git@192.168.119.48:bdyun/Portal.git
#cd /home/Portal/Portal && git pull origin developer:developer
cp -r /home/Portal/Portal $PORTAL
echo -e "${GREEN_COLOR}成功克隆云平台代码${RES}"
echo -e "${GREEN_COLOR}========================================================${RES}"

#云平台打包
function usage(){
    echo -e "${RED_COLOR}输入有误！请输入正确的版本编号：{1\2\3}${RES}"
    chose
}

function menu(){


cat <<EFO

        #########################
        #    1.打包博大版本;    #
        #    2.打包中兴版本;    #
        #    3.退出脚本程序.    #
        #########################

EFO
}

function chose(){

case "$fruit" in
    1)
       echo -e "${GREEN_COLOR}博达版本${RES}"
       Type=1
       cd $BDYUN && ./init_bdyun_version.sh && ./build_64_deb.sh
       ;;
    2)
       echo -e "${BLUE_COLOR}中兴版本${RES}"
       Type=2
       cd $PORTAL && chmod +x update_version_time.py && python update_version_time.py
       cd $ZTE && chmod +x build_64_deb.https.sh && ./build_64_deb.https.sh
       ;;
    3)
       echo -e "${RED_COLOR}成功退出${RES}"
       ;;
    *)
       usage
esac
}

function main(){
menu
chose
}
main

#安装云平台
echo "###################传输安装包####################"
echo "$PORTAL/`ls $PORTAL |grep amd64.deb`"
scp $PORTAL/`ls $PORTAL |grep amd64.deb` root@192.168.119.84:/tmp/
#scp zteportal_4.0_amd64.deb admin@192.168.119.101:/var/services/homes/admin/Install_package
echo "###################传输安装包####################"

function usage_install(){
    echo -e "${RED_COLOR}打包已完成是否选择安装：{1\2\3}${RES}"
    exit 1
}

function menu_install(){
cat <<EFO

        ###########################
        #    1.安装博达云平台;    #
        #    2.安装中兴云平台;    #
        #    3.退安装程序！       #
        ###########################

EFO
}

function chose_install(){
#read -p "请选择是否安装云平台版本的编号（1\2）：" fruit
case "$Type" in
    1)
       echo -e "${GREEN_COLOR}-------开始安装博达云平台-------${RES}"
       ssh -t -p $port $user@$ip $cmd1
       echo -e "${GREEN_COLOR}-------安装完成-------${RES}"
       ;;
    2)
       echo -e "${RED_COLOR}-------开始安装中兴云平台-------${RES}"
       ssh -t -p $port $user@$ip $cmd2
       echo -e "${GREEN_COLOR}-------安装完成-------${RES}"
       ;;
    3)
       echo -e "${RED_COLOR}成功退出${RES}"
       ;;
    *)
       usage
esac
}

function main(){
menu_install
chose_install
}
main

#制作ISO镜像
read -p "是否制作镜像(yes/no）：" ISO
while [[ $ISO != '' ]] && [ $ISO != 'yes' ] && [ $ISO != 'no' ]
do
read -p "输入错误，请输入“yes/no”" ISO
done
if [[ $ISO == '' ]] || [ $ISO == 'yes' ]
  then
    echo "---------------------开始制作镜像----------------------"
    ssh -t -p $port $user@$ip $cmd3
elif [ $ISO == 'no' ]
  then
    echo -e "${RED_COLOR}成功退出${RES}"
fi
#scp $PORTAL/`ls $PORTAL |grep amd64.deb` admin@192.168.119.101:/var/services/homes/admin/Linux-iso/iso_auto
#scp portal_auto.sh admin@192.168.119.101:/var/services/homes/admin/Linux-iso/iso_auto
#ssh -t -p $port $user@$ip $cmd3
