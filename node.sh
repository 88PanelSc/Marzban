#!/bin/bash
sfile=""

#domain
read -rp "Masukkan Domain: " domain
echo "$domain" > /root/domain
domain=$(cat /root/domain)

#certnode
read -rp "Masukkan cert: " cert

#PortENV
read -rp "Masukkan Service Port: " PORT1
read -rp "Masukkan API Port: " PORT2

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

#install toolkit
apt-get install libio-socket-inet6-perl libsocket6-perl git libcrypt-ssleay-perl libnet-libidn-perl perl libio-socket-ssl-perl libwww-perl libpcre3 libpcre3-dev zlib1g-dev dbus iftop zip unzip wget net-tools curl nano sed screen gnupg gnupg1 bc apt-transport-https build-essential dirmngr dnsutils sudo at htop iptables bsdmainutils cron lsof lnav -y

#install certfile
apt install iptables -y
apt install curl socat xz-utils wget apt-transport-https gnupg gnupg2 gnupg1 dnsutils lsb-release -y 
apt install socat cron bash-completion -y

#Set Timezone GMT+7
timedatectl set-timezone Asia/Jakarta;

#install Marzban-node
git clone https://github.com/Gozargah/Marzban-node /var/lib/marzban-node
cd /var/lib/marzban-node
sudo apt install python3 python3-pip -y 
sudo pip install -r requirements.txt
cp marzban.service /etc/systemd/system/marzban-node.service
sudo systemctl daemon-reload
sudo systemctl enable marzban-node
cat > /var/lib/marzban-node/.env << END
SERVICE_PORT=$PORT1
XRAY_API_PORT=$PORT2
XRAY_EXECUTABLE_PATH=/var/lib/marzban-node/core/xray
XRAY_ASSETS_PATH=/var/lib/marzban-node/assets
SSL_CERT_FILE=/var/lib/marzban-node/ssl_cert.pem
SSL_KEY_FILE=/var/lib/marzban-node/ssl_key.pem
SSL_CLIENT_CERT_FILE=/var/lib/marzban-node/ssl_client_cert.pem
DEBUG=False
END
echo "$cert" > /var/lib/marzban-node/ssl_client_cert.pem
cd

#install assets & core
mkdir -p /var/lib/marzban/assets
mkdir -p /var/lib/marzban-node/assets
mkdir -p /var/lib/marzban-node/core
wget -O /var/lib/marzban-node/core/xray "$sfile/marzban/core/xray" && chmod +x /var/lib/marzban-node/core/xray
wget -O /var/lib/marzban-node/assets/geositeindo.dat "$sfile/marzban/GeoSite.dat"
chmod +x /var/lib/marzban-node/assets/geositeindo.dat
wget -O /var/lib/marzban-node/assets/geoip.dat "$sfile/marzban/GeoIP.dat"
chmod +x /var/lib/marzban-node/assets/geoip.dat

#profile
echo -e 'profile' >> /root/.profile
wget -O /usr/bin/profile "$sfile/marzban/profile-2";
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
wget -O /etc/nginx/conf.d/xray.conf "$sfile/marzban/xray.conf"
systemctl enable nginx
mkdir -p /var/www/html
echo "<pre>Setup by SecretSociety</pre>" > /var/www/html/index.html
systemctl restart nginx

#install command
cd /usr/bin
wget -O clearlog "$sfile/marzban/clearlog" && chmod +x clearlog
wget -O ceklog "$sfile/marzban/ceklog" && chmod +x ceklog
wget -O cekerror "$sfile/marzban/cekerror" && chmod +x cekerror
wget -O ceknginx "$sfile/marzban/ceknginx" && chmod +x ceknginx
cd

#Install reboot & backup otomatis 
wget -O /root/reboot_otomatis.sh "$sfile/alltr/reboot_otomatis.sh";
chmod +x /root/reboot_otomatis.sh;
echo "30 4 * * * root /root/reboot_otomatis.sh" > /etc/cron.d/reboot_otomatis;
echo "0 */6 * * * root /usr/bin/clearlog" >> /etc/cron.d/clearlog
systemctl restart cron;

#install Firewall
apt install ufw -y
apt install fail2ban -y
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow http
sudo ufw allow https
sudo ufw allow 8081/tcp
sudo ufw allow 7879/tcp
sudo ufw allow 1080/tcp
sudo ufw allow 1080/udp
sudo ufw allow $PORT1:$PORT2/tcp
yes | sudo ufw enable

#install cf 
wget -O /root/warp "https://raw.githubusercontent.com/hamid-gh98/x-ui-scripts/main/install_warp_proxy.sh"
sudo chmod +x /root/warp
sudo bash /root/warp -y 

#finishing
apt autoremove -y
apt clean
sudo systemctl restart nginx
sudo systemctl start marzban-node
sudo systemctl status marzban-node
echo "Instalasi Marzban-node sukses"
echo "Menunggu cert file dibuat"
sleep 15
echo "Copy cert file dibawah ke Main server:"
sudo cat /var/lib/marzban-node/ssl_cert.pem