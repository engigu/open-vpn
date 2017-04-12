#!/bin/bash
PATH=/bin:/sbin:/usr/bin:/usr/sbin:/usr/local/bin:/usr/local/sbin:~/bin
export PATH
clear;
rm -- "$0" 
rm -f openvpn
ServerLocation='yaohuo';
MirrorHost='https://raw.githubusercontent.com/EngiGu/open-vpn/master/';
IPAddress=`wget http://members.3322.org/dyndns/getip -O - -q ; echo`;
pass=`wget https://raw.githubusercontent.com/EngiGu/open-vpn/master/yaohuo/fuck.php -O - -q ; echo`;
#fuck.php内的文件内容是yaohuo.me用MD5加密后的内容


#==========================================================================
Welcome='
==========================================================================
                                   欢迎使用
                               
                         Powered by yaohuo.me 2015-2016                     
                              All Rights Reserved                  
                                                                            
==========================================================================';

Error='
==========================================================================
                          妖火免流服务验证失败，安装被终止
                               
                         Powered by yaohuo.me 2015-2016                     
                              All Rights Reserved                  
                                                                            
==========================================================================';

InstallError='
==========================================================================
                            妖火免流服务安装失败
                               
                         Powered by yaohuo.me 2015-2016                     
                              All Rights Reserved                  
                                                                            
==========================================================================';

InstallOK='
                             妖火免流服务 安装完毕                                
                         Powered by yaohuo.me 2015-2016                     
                              All Rights Reserved                                                           
==========================================================================';

#==========================================================================
echo "
======================================================================="
echo
echo -e "\e[1;35m\n                             欢迎使用 
                                
            腾讯/阿里-Centos6.x-OpenVPN-云免服务器搭建脚本
		 
               搭建模式为：流控+HTTP转接+常规=共存模式
			更新实时流控监控脚本

                 妖火网-yaohuo.me-西门吹雪-ID:18306
                          
                                              
                                                             西门吹雪      
                                                            2016-07-15 
\e[0m"
echo "======================================================================="
echo 
echo "脚本已由阿里云/腾讯云  测试通过"
echo 
echo -n "请输入妖火论坛网址： "
read PASSWD
key=`echo -n $PASSWD|md5sum`
if [[ ${key%%\ *} == $pass ]]
    then
        echo 
        echo 验证成功！[本机IP：$IPAddress]
    else
        echo
        echo "验证失败！"		
		echo "$Error";
		
exit 0;
fi

echo -n "  请输入后台管理员密码："
read SuperPass
if [ -z $SuperPass ]
	then
		echo -n "  密码不能为空，请重新输入："
		read SuperPass
fi 

echo -n "  请输入数据库密码："
read MySQLPass
if [ -z $MySQLPass ]
	then
		echo -n "  密码不能为空，请重新输入："
		read MySQLPass
fi 

echo
function InputIPAddress()
{
	if [ "$IPAddress" == '' ]; then
		echo '无法检测您的IP';
		read -p '请输入您的公网IP:' IPAddress;
		[ "$IPAddress" == '' ] && InputIPAddress;
	fi;
	[ "$IPAddress" != '' ] && echo -n '[  OK  ] 您的IP是:' && echo $IPAddress;
	sleep 2
}
#YHML
rm -rf /passwd
echo "系统正在安装OpenVPN服务，请耐心等待："
echo 
echo -n "正在检测网卡..."
if [ ! -e "/dev/net/tun" ];
    then
	    echo
		echo "安装被终止！"
        echo "TUN/TAP网卡未开启，请联系服务商开启TUN/TAP。"
		echo 
		echo "如果你是网易蜂巢Centos 6.7，请到妖火网查看网易蜂巢服务安装方式！"
        exit 0;
	else
	    echo "                 [  OK  ]"
fi

#YHML
echo -e "\033[31m正在部署环境..\033[0m"
sleep 1
service openvpn stop >/dev/null 2>&1
killall squid >/dev/null 2>&1
rm -rf /etc/openvpn/*
rm -rf /home/openvpn.tar.gz
rm -rf /etc/squid
rm -rf /passwd


yum update -y

rpm -ivh ${MirrorHost}/${ServerLocation}/epel-release-6-8.noarch.rpm --force >/dev/null 2>&1
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-EPEL-6
rpm -ivh ${MirrorHost}/${ServerLocation}/remi-release-6.rpm --force >/dev/null 2>&1
rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-remi
yum clean all
yum makecache
sleep 5
yum install -y squid openssl openssl-devel lzo lzo-devel pam pam-devel automake pkgconfig curl tar expect unzip
yum install -y openvpn

#YHML
echo "配置网络环境..."
iptables -F >/dev/null 2>&1
service iptables save >/dev/null 2>&1
service iptables restart >/dev/null 2>&1
iptables -t nat -A POSTROUTING -s 10.8.0.0/16 -o eth0 -j MASQUERADE >/dev/null 2>&1
iptables -A INPUT -p TCP --dport 443 -j ACCEPT >/dev/null 2>&1
iptables -A INPUT -p TCP --dport 80 -j ACCEPT >/dev/null 2>&1
iptables -A INPUT -p TCP --dport 8080 -j ACCEPT >/dev/null 2>&1
iptables -A INPUT -p TCP --dport 666 -j ACCEPT >/dev/null 2>&1
iptables -A INPUT -p TCP --dport 3306 -j ACCEPT >/dev/null 2>&1
iptables -A INPUT -p TCP --dport 22 -j ACCEPT >/dev/null 2>&1
iptables -t nat -A POSTROUTING -j MASQUERADE >/dev/null 2>&1
iptables -A INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT >/dev/null 2>&1
service iptables save
service iptables restart
chkconfig iptables on
setenforce 0

#YHML
echo "正在安装配置文件，请稍后......."
sleep 1
cd /bin
rm -rf xmcx
wget ${MirrorHost}/${ServerLocation}/xmcx >/dev/null 2>&1
chmod 777 xmcx

sleep 1
cd /etc
rm -f sysctl.conf
wget ${MirrorHost}/${ServerLocation}/sysctl.conf >/dev/null 2>&1
chmod 777 /etc/sysctl.conf
sysctl -p >/dev/null 2>&1

cd /etc/squid
rm -f squid.conf squid_passwd
wget ${MirrorHost}/${ServerLocation}/squid.conf >/dev/null 2>&1
wget ${MirrorHost}/${ServerLocation}/squid_passwd >/dev/null 2>&1
chmod 0755 squid.conf squid_passwd

cd /etc/openvpn
rm -f server-passwd.tar.gz EasyRSA-2.2.2.tar.gz YHML peizhi.cfg
wget ${MirrorHost}/${ServerLocation}/EasyRSA-2.2.2.tar.gz >/dev/null 2>&1
wget ${MirrorHost}/${ServerLocation}/peizhi.cfg >/dev/null 2>&1
wget ${MirrorHost}/${ServerLocation}/server-passwd.tar.gz >/dev/null 2>&1
tar -zxvf EasyRSA-2.2.2.tar.gz >/dev/null 2>&1
tar -zxvf server-passwd.tar.gz >/dev/null 2>&1
sed -i "s/MySQLPass/$MySQLPass/g" /etc/openvpn/disconnect.sh 
sed -i "s/MySQLPass/$MySQLPass/g" /etc/openvpn/login.sh
sed -i "s/MySQLPass/$MySQLPass/g" /etc/openvpn/peizhi.cfg
chmod -R 0777 /etc/openvpn

echo "请稍等，正在安装LAMP环境"
yum -y install httpd
chkconfig httpd on
sed -i 's/#ServerName www.example.com:80/ServerName www.example.com:666/g' /etc/httpd/conf/httpd.conf >/dev/null 2>&1
sed -i 's/Listen 80/Listen 666/g' /etc/httpd/conf/httpd.conf >/dev/null 2>&1
service httpd start
yum remove -y mysql*
yum --enablerepo=remi install -y mysql mysql-server mysql-devel
sleep 3
chkconfig mysqld on
service mysqld start 
sleep 3
yum --enablerepo=remi install -y php php-mysql php-gd
service httpd restart

echo "请稍等，正在配置WEB面板"
cd /var
rm -rf www
rm -rf html
wget ${MirrorHost}/${ServerLocation}/WEB-YHML.tar.gz >/dev/null 2>&1
sleep 1
tar -zxvf WEB-YHML.tar.gz >/dev/null 2>&1
sleep 1
rm -f WEB-YHML.tar.gz
cd /var/www
mysqladmin -u root password $MySQLPass
mysql -uroot -p$MySQLPass -e"DROP DATABASE test;"
mysql -uroot -p$MySQLPass -e"CREATE DATABASE ov;"
mysql -uroot -p$MySQLPass ov < ov.sql
rm -f ov.sql
sed -i "s/MySQLPass/$MySQLPass/g" /var/www/html/config.php >/dev/null 2>&1
sed -i "s/SuperPass/$SuperPass/g" /var/www/html/config.php >/dev/null 2>&1
echo "请稍等，正在部署实时流控监控脚本"
sleep 1
cd /var/www/html/res/
rm -f jiankong
wget ${MirrorHost}/${ServerLocation}/jiankong >/dev/null 2>&1
chmod -R 0777 /var/www/html
echo "部署完成~~~~"
#
sleep 1
cd /etc/openvpn
cd /etc/openvpn/easy-rsa/
source vars  2>&1
./clean-all  2>&1
sleep 1
echo "正在生成CA/服务端证书..."
./ca && ./centos centos >/dev/null 2>&1
echo "证书创建完成 "
echo "正在生成TLS密钥..."
sleep 2
openvpn --genkey --secret ta.key
echo "正在生成SSL加密证书，这是一个漫长的等待过程..."
sleep 1
./build-dh

echo "正在启动服务..."
squid –z >/dev/null 2>&1
squid -s >/dev/null 2>&1
chkconfig openvpn on  >/dev/null 2>&1
chkconfig squid on >/dev/null 2>&1
service squid start >/dev/null 2>&1
service openvpn start >/dev/null 2>&1
cd /bin >/dev/null 2>&1
./xmcx -l 8080 -d >/dev/null 2>&1

echo "正在写入快捷命令..."
cd /bin
rm -f YHML
wget ${MirrorHost}/${ServerLocation}/vpn1 >/dev/null 2>&1
mv vpn1 /bin/YHML
chmod 0777 /bin/YHML
echo "sh /bin/YHML" >>/etc/rc.d/rc.local

#YHML
cp /etc/openvpn/easy-rsa/keys/ca.crt /home/ >/dev/null 2>&1
cp /etc/openvpn/easy-rsa/ta.key /home/ >/dev/null 2>&1
cd /home/ >/dev/null 2>&1
clear
echo
echo 
echo "正在生成OpenVPN-HTTP.ovpn配置文件..."
echo 
echo 
echo "写入前端代码"
sleep 1
echo '# 妖火免流配置
# HTTP转接模式
# 妖火网-yaohuo.me ID:18306
setenv IV_GUI_VER "de.blinkt.openvpn 0.6.17" 
machine-readable-output
client
dev tun
proto tcp
connect-retry-max 5
connect-retry 5
resolv-retry 60
########免流代码########
remote wap.17wo.cn 80
http-proxy-option EXT1 POST http://wap.17wo.cn
http-proxy-option EXT1 Host wap.17wo.cn' >ovpn.1
echo 写入代理端口 （$IPAddress:8080）
sleep 1
echo http-proxy $IPAddress 8080 >myip
cat ovpn.1 myip>ovpn.2
echo '########免流代码########
' >ovpn.3
cat ovpn.2 ovpn.3>ovpn.4
echo "<http-proxy-user-pass>" >>ovpn.4
echo root >>ovpn.4
echo YHML >>ovpn.4
echo "</http-proxy-user-pass>
" >>ovpn.4
echo resolv-retry infinite >ovpn.5
cat ovpn.4 ovpn.5>ovpn.6
echo "写入中端代码"
sleep 1
echo 'nobind
persist-key
persist-tun
push route 114.114.114.144 114.114.115.115

<ca>' >ovpn.7
cat ovpn.6 ovpn.7>ovpn.8
echo "写入CA证书"
sleep 2
cat ovpn.8 ca.crt>ovpn.9
echo '</ca>
key-direction 1
<tls-auth>' >ovpn.10
cat ovpn.9 ovpn.10>ovpn.11
echo "写入TLS密钥"
sleep 1
cat ovpn.11 ta.key>ovpn.12
echo "写入后端代码"
sleep 1
echo '</tls-auth>
auth-user-pass
ns-cert-type server
comp-lzo
verb 3
' >ovpn.13
echo "生成OpenVPN-HTTP.ovpn文件"
sleep 1
cat ovpn.12 ovpn.13>OpenVPN-HTTP.ovpn
echo "配置文件制作完毕"
echo
rm -rf ./{myip,ovpn.1,ovpn.2,ovpn.3,ovpn.4,ovpn.5,ovpn.6,ovpn.7,ovpn.8,ovpn.9,ovpn.10,ovpn.11,ovpn.12,ovpn.13,ovpn.14,ovpn.15,ovpn.16}
sleep 2
clear

echo
echo 
echo "正在生成OpenVPN.ovpn配置文件..."
echo 
echo 
echo "写入前端代码"
sleep 3
echo '# 妖火免流配置
# 本文件由系统自动生成
# 常规模式
# 妖火网-yaohuo.me ID:18306
setenv IV_GUI_VER "de.blinkt.openvpn 0.6.17" 
machine-readable-output
client
dev tun
proto tcp
connect-retry-max 5
connect-retry 5
resolv-retry 60
########免流代码########
http-proxy-option EXT1 "POST http://wap.10010.com" 
http-proxy-option EXT1 "GET http://wap.10010.com" 
http-proxy-option EXT1 "X-Online-Host: wap.10010.com" 
http-proxy-option EXT1 "POST http://wap.10010.com" 
http-proxy-option EXT1 "X-Online-Host: wap.10010.com" 
http-proxy-option EXT1 "POST http://wap.10010.com" 
http-proxy-option EXT1 "Host: wap.10010.com" 
http-proxy-option EXT1 "GET http://wap.10010.com" 
http-proxy-option EXT1 "Host: wap.10010.com"' >ovpn.1
echo 写入代理端口 （$IPAddress:80）
sleep 1
echo http-proxy $IPAddress 80 >myip
cat ovpn.1 myip>ovpn.2
echo '########免流代码########
' >ovpn.3
cat ovpn.2 ovpn.3>ovpn.4
echo "<http-proxy-user-pass>" >>ovpn.4
echo root >>ovpn.4
echo YHML >>ovpn.4
echo "</http-proxy-user-pass>
" >>ovpn.4
echo 写入OpenVPN端口 （$IPAddress:443）
echo remote $IPAddress 443 >ovpn.5
cat ovpn.4 ovpn.5>ovpn.6
echo "写入中端代码"
sleep 1
echo 'resolv-retry infinite
nobind
persist-key
persist-tun
push route 114.114.114.144 114.114.115.115

<ca>' >ovpn.7
cat ovpn.6 ovpn.7>ovpn.8
echo "写入CA证书"
sleep 1
cat ovpn.8 ca.crt>ovpn.9
echo '</ca>
key-direction 1
<tls-auth>' >ovpn.10
cat ovpn.9 ovpn.10>ovpn.11
echo "写入TLS密钥"
sleep 1
cat ovpn.11 ta.key>ovpn.12
echo "写入后端代码"
echo '</tls-auth>
auth-user-pass
ns-cert-type server
comp-lzo
verb 3
' >ovpn.13
echo "生成OpenVPN.ovpn文件"
cat ovpn.12 ovpn.13>OpenVPN.ovpn
echo "配置文件制作完毕"
echo
rm -rf ./{myip,ovpn.1,ovpn.2,ovpn.3,ovpn.4,ovpn.5,ovpn.6,ovpn.7,ovpn.8,ovpn.9,ovpn.10,ovpn.11,ovpn.12,ovpn.13,ovpn.14,ovpn.15,ovpn.16}
sleep 2

tar -zcvf OpenVPN-YHML.tar.gz ./{OpenVPN-HTTP.ovpn,OpenVPN.ovpn,ca.crt,ta.key} >/dev/null 2>&1
cp OpenVPN-YHML.tar.gz /var/www/html/OpenVPN-YHML.tar.gz
rm -rf ./{ta.key,ca.crt,user01.{crt,key}}
clear
echo
# OpenVPN Installing ****************************************************************************
echo 
echo ————重启命令————YHML
echo 
echo ————控制面板为 http://$IPAddress:666 管理后台为 http://$IPAddress:666/admin
echo
echo ————配置文件下载地址 http://$IPAddress:666/OpenVPN-YHML.tar.gz
echo
echo ————管理账号 admin————密码 $SuperPass 
echo
echo ————欢迎访问官网论坛：www.yaohuo.me—妖火网-分享你我
echo "$InstallOK";
rm -rf url
rm -rf /openvpn /root/openvpn /home/openvpn
rm -rf /etc/openvpn/server-passwd.tar.gz /etc/openvpn/ca
rm -f /etc/openvpn/EasyRSA-2.2.2.tar.gz
exit 0;
# OpenVPN Installation Complete ****************************************************************************