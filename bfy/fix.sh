#!bin/bash
rm -f $0
rm -f fix.sh
echo "程序载入中，请稍后..."
sleep 2
if [ ! -e "/home/wwwroot/default/user/app_api.php" ];then
echo "您的服务器还未搭建缤纷云openvpn"
exit 0;
fi
IP=`curl -s http://members.3322.org/dyndns/getip`;
echo -e "欢迎使用缤纷云控2.1升级2.2脚本";
echo "鸣谢修补制作:情空明月 http://myxw.ml"
echo -n " 请输入流控端口【回车默认；1234】："
read port
if [[ -z $port ]] 
then 
echo
echo -e "\033[34m你输入的端口为：1234 \033[0m" 
port=1234
else 
echo
echo -e "\033[34m你输入的流控端口为：$port \033[0m" 
fi
echo "请输入要修改的IP地址:";
read IP
echo "修复中"
sleep 2
sed -i 's/apphost=www.qyunl.com;/'apphost=$IP:$port'/g' /etc/openvpn/peizhi.cfg
wget http://sh.awayun.cn/two-two.zip >/dev/null 2>&1
unzip two-two.zip >/dev/null 2>&1
rm -rf two-two.zip >/dev/null 2>&1
rm -rf /home/wwwroot/default/banben.php 2>&1
rm -rf /home/wwwroot/default/admin/open.php 2>&1
mv /root/open.php /home/wwwroot/default/admin/open.php 2>&1
mv /root/banben.php /home/wwwroot/default/banben.php 2>&1
chmod -R  0777 /home/wwwroot/default/banben.php 2>&1
chmod -R  0777 /home/wwwroot/default/admin/open.php 2>&1
sleep 2
echo "升级完成"
echo "鸣谢修补制作:情空明月 http://myxw.ml"
exit 0;
