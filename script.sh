#!/bin/bash


# =========================
# VERIFICATION ROOT
# =========================
if [ "$EUID" -ne 0 ]; then
  echo "Ce script ne peut être lancer qu'en root."
  exit 1
fi

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
wget \
winbind \ 
samba

updatedb

# =========================
# NETBIOS
# =========================

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
reboot

