#!/bin/bash

echo "=== Baseline CLI Debian - Post Install ==="

# =========================
# VERIFICATION ROOT
# =========================
if [ "$EUID" -ne 0 ]; then
  echo "Lance ce script en root."
  exit 1
fi

# =========================
# VARIABLES CONFIG RESEAU
# =========================
IP_ADDR="192.168.1.50"
NETMASK="255.255.255.0"
GATEWAY="192.168.1.254"
DNS1="192.168.1.254"
DNS2="1.1.1.1"
DNS3="8.8.8.8"
DOMAIN="."

# =========================
# DETECTION INTERFACE
# =========================
IFACE=$(ip -o link show | awk -F': ' '{print $2}' | grep -v lo | head -n 1)
echo "Interface détectée : $IFACE"

# =========================
# MISE A JOUR
# =========================
echo ">>> Mise à jour du système"
apt update && apt upgrade -y

# =========================
# OUTILS DE BASE
# =========================
echo ">>> Installation outils de base"
apt install -y \
ssh \
zip unzip \
nmap \
locate \
ncdu \
curl \
git \
screen \
dnsutils \
net-tools \
sudo \
lynx \
wget

updatedb

# =========================
# NETBIOS
# =========================
echo ">>> Installation NetBIOS"
apt install -y winbind samba

echo ">>> Configuration nsswitch (écriture directe)"

# Réécriture complète propre du fichier
echo "passwd:         files systemd" > /etc/nsswitch.conf
echo "group:          files systemd" >> /etc/nsswitch.conf
echo "shadow:         files systemd" >> /etc/nsswitch.conf
echo "" >> /etc/nsswitch.conf
echo "hosts:          files dns wins" >> /etc/nsswitch.conf
echo "" >> /etc/nsswitch.conf
echo "networks:       files" >> /etc/nsswitch.conf
echo "protocols:      db files" >> /etc/nsswitch.conf
echo "services:       db files" >> /etc/nsswitch.conf
echo "ethers:         db files" >> /etc/nsswitch.conf
echo "rpc:            db files" >> /etc/nsswitch.conf
echo "" >> /etc/nsswitch.conf
echo "netgroup:       nis" >> /etc/nsswitch.conf

# =========================
# BASH ROOT (simple, direct)
# =========================
echo ">>> Personnalisation bash root"

echo "export LS_OPTIONS='--color=auto'" > /root/.bashrc
echo "eval \"\$(dircolors)\"" >> /root/.bashrc
echo "alias ls='ls \$LS_OPTIONS'" >> /root/.bashrc
echo "alias ll='ls \$LS_OPTIONS -l'" >> /root/.bashrc
echo "alias l='ls \$LS_OPTIONS -A'" >> /root/.bashrc

# =========================
# CONFIG RESEAU STATIQUE
# =========================
echo ">>> Configuration IP statique"

echo "auto lo" > /etc/network/interfaces
echo "iface lo inet loopback" >> /etc/network/interfaces
echo "" >> /etc/network/interfaces
echo "auto $IFACE" >> /etc/network/interfaces
echo "iface $IFACE inet static" >> /etc/network/interfaces
echo "    address $IP_ADDR" >> /etc/network/interfaces
echo "    netmask $NETMASK" >> /etc/network/interfaces
echo "    gateway $GATEWAY" >> /etc/network/interfaces
echo "    dns-nameservers $DNS1 $DNS2 $DNS3" >> /etc/network/interfaces
echo "    dns-search $DOMAIN" >> /etc/network/interfaces

systemctl restart networking

# =========================
# DNS (verrouillé)
# =========================
echo ">>> Configuration DNS"

echo "search $DOMAIN" > /etc/resolv.conf
echo "nameserver $DNS1" >> /etc/resolv.conf
echo "nameserver $DNS2" >> /etc/resolv.conf
echo "nameserver $DNS3" >> /etc/resolv.conf

chattr +i /etc/resolv.conf

# =========================
# INSTALLATION WEBMIN
# =========================
echo ">>> Installation Webmin"

wget -O /tmp/webmin-setup-repo.sh \
https://raw.githubusercontent.com/webmin/webmin/master/webmin-setup-repo.sh

yes | sh /tmp/webmin-setup-repo.sh

apt update
apt install -y webmin --install-recommends

echo ">>> Webmin : https://$IP_ADDR:10000"

# =========================
# FIN
# =========================
echo ">>> Baseline terminée."
echo ">>> Redémarrage recommandé."

