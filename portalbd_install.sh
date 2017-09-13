#!/usr/bin/env bash

source /etc/profile

dpkg -l |grep zte |awk '{print $2}' |xargs dpkg --purge >/dev/null 2>&1
mysql -uroot -pbdyun -e "drop database radius;" 2>&1
mysql -uroot -pbdyun -e "show databases;"

dpkg -i /tmp/bdyun_4.0_amd64.deb

mysql -uroot -pbdyun -e "show databases;"
curl 192.168.119.84:8080 |grep title |awk '{print $1}'
