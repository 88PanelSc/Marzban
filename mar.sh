#!/bin/bash
sfile=""

#email
read -rp "Masukkan Email anda: " email

#domain
read -rp "Masukkan Domain: " domain
echo "$domain" > /root/domain
domain=$(cat /root/domain)

#token
read -rp "Masukkan UsernamePanel: " userpanel
echo "$userpanel" > /root/userpanel
read -rp "Masukkan PasswordPanel: " passpanel
echo "$passpanel" > /root/passpanel

#nameregis
read -rp "Masukkan ISP VPS: " nama
echo "$nama" > /root/nama

#Pass Backup
read -rp "Masukkan Pass untuk file Backup: " fileb
echo "$fileb" > /root/passbackup

#Preparation
clear
cd;
apt-get update;

#Remove unused Module
apt-get -y --purge remove samba*;
apt-get -y --purge remove apache2*;
apt-get -y --purge remove sendmail*;
apt-get -y --purge remove bind9*;

#install sysctl
wget -O /etc/sysctl.conf "$sfile/marzban/sysctl.conf"
sysctl -p

#install benchmark
wget -O /usr/bin/bench "https://raw.githubusercontent.com/teddysun/across/master/bench.sh" && chmod +x /usr/bin/bench

#install toolkit
apt-get install libio-socket-inet6-perl libsocket6-perl libcrypt-ssleay-perl libnet-libidn-perl perl libio-socket-ssl-perl libwww-perl libpcre3 libpcre3-dev zlib1g-dev dbus iftop zip unzip wget net-tools curl nano sed screen gnupg gnupg1 bc apt-transport-https build-essential dirmngr dnsutils sudo at htop iptables bsdmainutils cron lsof lnav -y

#Install lolcat
apt-get install -y ruby;
gem install lolcat;

#Set Timezone GMT+7
timedatectl set-timezone Asia/Jakarta;

#Install Marzban
sudo bash -c "$(curl -sL https://github.com/GawrAme/Marzban-scripts/raw/master/marzban.sh)" @ install

#install subs
wget -O /opt/marzban/index.html "https://cdn.jsdelivr.net/gh/MuhammadAshouri/marzban-templates@master/template-01/index.html"

#install env
wget -O /opt/marzban/.env "$sfile/marzban/env"

#install compose
wget -O /opt/marzban/docker-compose.yml "$sfile/marzban/docker-compose.yml"

#install assets & core
touch /var/lib/marzban/akun-trojan.conf
touch /var/lib/marzban/akun-vmess.conf
touch /var/lib/marzban/akun-vless.conf
touch /var/lib/marzban/akun-ss.conf
mkdir -p /var/lib/marzban/assets
mkdir -p /var/lib/marzban/core
mkdir -p /var/lib/marzban/logs
wget -O /var/lib/marzban/assets/geositeindo.dat "$sfile/marzban/GeoSite.dat"
chmod +x /var/lib/marzban/assets/geositeindo.dat
wget -O /var/lib/marzban/assets/geoip.dat "$sfile/marzban/GeoIP.dat"
chmod +x /var/lib/marzban/assets/geoip.dat

#profile
echo -e 'profile' >> /root/.profile
wget -O /usr/bin/profile "$sfile/marzban/profile";
chmod +x /usr/bin/profile
apt install neofetch -y

#Install VNSTAT
apt -y install vnstat
/etc/init.d/vnstat restart
apt -y install libsqlite3-dev
wget $sfile/marzban/vnstat-2.6.tar.gz
tar zxvf vnstat-2.6.tar.gz
cd vnstat-2.6
./configure --prefix=/usr --sysconfdir=/etc && make && make install 
cd
chown vnstat:vnstat /var/lib/vnstat -R
systemctl enable vnstat
/etc/init.d/vnstat restart
rm -f /root/vnstat-2.6.tar.gz 
rm -rf /root/vnstat-2.6

#Install Speedtest
curl -s https://packagecloud.io/install/repositories/ookla/speedtest-cli/script.deb.sh | sudo bash
sudo apt-get install speedtest -y

#install gotop
git clone --depth 1 https://github.com/cjbassi/gotop /tmp/gotop
/tmp/gotop/scripts/download.sh
cp /root/gotop /usr/bin/
chmod +x /usr/bin/gotop
cd

#install nginx
apt install nginx -y
rm /etc/nginx/conf.d/default.conf
wget -O /etc/nginx/nginx.conf "$sfile/marzban/nginx.conf"
wget -O /etc/nginx/conf.d/vps.conf "$sfile/marzban/vps.conf"
wget -O /etc/nginx/conf.d/xray.conf "$sfile/marzban/xray_2.conf"
systemctl enable nginx
mkdir -p /var/www/html
echo "<pre>Setup by SecretSociety aka LingVPN</pre>" > /var/www/html/index.html
systemctl start nginx

#install socat
apt install iptables -y
apt install curl socat xz-utils wget apt-transport-https gnupg gnupg2 gnupg1 dnsutils lsb-release -y 
apt install socat cron bash-completion -y

#install cert
systemctl stop nginx
curl https://get.acme.sh | sh -s email=$email
/root/.acme.sh/acme.sh --server letsencrypt --register-account -m $email --issue -d $domain --standalone -k ec-256
~/.acme.sh/acme.sh --installcert -d $domain --fullchainpath /var/lib/marzban/xray.crt --keypath /var/lib/marzban/xray.key --ecc
systemctl start nginx
rm /var/lib/marzban/xray_config.json
wget -O /var/lib/marzban/xray_config.json "$sfile/marzban/xray_config.json"

#install command
cd /usr/bin
#List Trojan
wget -O addtrtcp "$sfile/marzban/addtrtcp" && chmod +x addtrtcp
wget -O addtrws "$sfile/marzban/addtrws" && chmod +x addtrws
wget -O addtrgrpc "$sfile/marzban/addtrgrpc" && chmod +x addtrgrpc
wget -O addtrojan "$sfile/marzban/addtrojan" && chmod +x addtrojan
wget -O deltrojan "$sfile/marzban/deltrojan" && chmod +x deltrojan
wget -O renewtrojan "$sfile/marzban/renewtrojan" && chmod +x renewtrojan
#Lits VMess
wget -O addvmtcp "$sfile/marzban/addvmtcp" && chmod +x addvmtcp
wget -O addvmws "$sfile/marzban/addvmws" && chmod +x addvmws
wget -O addvmgrpc "$sfile/marzban/addvmgrpc" && chmod +x addvmgrpc
wget -O addvmess "$sfile/marzban/addvmess" && chmod +x addvmess
wget -O delvmess "$sfile/marzban/delvmess" && chmod +x delvmess
wget -O renewvmess "$sfile/marzban/renewvmess" && chmod +x renewvmess
#List VLess
wget -O addvless "$sfile/marzban/addvless" && chmod +x addvless
wget -O addvltcp "$sfile/marzban/addvltcp" && chmod +x addvltcp
wget -O addvlws "$sfile/marzban/addvlws" && chmod +x addvlws
wget -O addvlgrpc "$sfile/marzban/addvlgrpc" && chmod +x addvlgrpc
wget -O delvless "$sfile/marzban/delvless" && chmod +x delvless
wget -O renewvless "$sfile/marzban/renewvless" && chmod +x renewvless
#List ShadowSocks
wget -O addshadow "$sfile/marzban/addshadow" && chmod +x addshadow
#Additional
wget -O menu "$sfile/marzban/menu" && chmod +x menu
wget -O ceklogin "$sfile/marzban/ceklogin" && chmod +x ceklogin
wget -O buatid "$sfile/marzban/buatid" && chmod +x buatid
wget -O buat_token "$sfile/marzban/buat_token" && chmod +x buat_token
wget -O cekservice "$sfile/marzban/cekservice" && chmod +x cekservice
wget -O ram "$sfile/addons/ram" && chmod +x ram
wget -O menu-backup "$sfile/marzban/menu-backup" && chmod +x menu-backup
wget -O backup "$sfile/marzban/backup" && chmod +x backup
wget -O clearlog "$sfile/marzban/clearlog" && chmod +x clearlog
wget -O allvpn "$sfile/marzban/allvpn" && chmod +x allvpn
wget -O ceklog "$sfile/marzban/ceklog" && chmod +x ceklog
wget -O cekerror "$sfile/marzban/cekerror" && chmod +x cekerror
wget -O ceknginx "$sfile/marzban/ceknginx" && chmod +x ceknginx
wget -O expired "$sfile/marzban/expired" && chmod +x expired
wget -O listuser "$sfile/marzban/listuser" && chmod +x listuser
wget -O cek-kuota "$sfile/marzban/cek-kuota" && chmod +x cek-kuota
wget -O setlimit "$sfile/marzban/setlimit" && chmod +x setlimit
wget -O autokill "$sfile/marzban/autokill" && chmod +x autokill
cd

#Install reboot, expired, dan clearlog otomatis
wget -O /root/reboot_otomatis.sh "$sfile/alltr/reboot_otomatis.sh";
chmod +x /root/reboot_otomatis.sh;
echo "30 4 * * * root /root/reboot_otomatis.sh" > /etc/cron.d/reboot_otomatis;
echo "0 0 * * * root /usr/bin/expired" > /etc/cron.d/expired;
echo "0 */6 * * * root /usr/bin/clearlog" >> /etc/cron.d/clearlog;
systemctl restart cron;

#install Firewall
apt install ufw -y
apt install fail2ban -y
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow http
sudo ufw allow https
sudo ufw allow 1080/tcp
sudo ufw allow 2082/tcp
sudo ufw allow 2083/tcp
sudo ufw allow 3128/tcp
sudo ufw allow 8080/tcp
sudo ufw allow 8443/tcp
sudo ufw allow 8880/tcp
sudo ufw allow 8081/tcp
sudo ufw allow 7879/tcp
yes | sudo ufw enable
systemctl enable ufw
systemctl start ufw

#install database
wget -O /var/lib/marzban/db.sqlite3 "$sfile/marzban/db.sqlite3"

#install cf 
wget -O /root/warp "https://raw.githubusercontent.com/hamid-gh98/x-ui-scripts/main/install_warp_proxy.sh"
sudo chmod +x /root/warp
sudo bash /root/warp -y 

#finishing
apt autoremove -y
apt clean
cd /opt/marzban
docker compose down && docker compose up -d
systemctl restart nginx
buat_token
cd
rm /root/mar.sh