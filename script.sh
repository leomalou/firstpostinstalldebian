#!/bin/bash

# =========================
# MISE A JOUR
# =========================

apt update && apt upgrade -y

# =========================
# OUTILS DE BASE
# =========================

apt install  ssh zip unzip nmap locate ncdu curl git screen dnsutils net-tools sudo lynx wget winbind samba -y
updatedb

# =========================
# configuration nsswitch
# =========================

# Réécriture du fichier
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
# Modification BASHRC 
# =========================

echo "export LS_OPTIONS='--color=auto'" > /root/.bashrc
echo "eval \"\$(dircolors)\"" >> /root/.bashrc
echo "alias ls='ls \$LS_OPTIONS'" >> /root/.bashrc
echo "alias ll='ls \$LS_OPTIONS -l'" >> /root/.bashrc
echo "alias l='ls \$LS_OPTIONS -A'" >> /root/.bashrc

# =========================
# Installation WEBMIN
# =========================

wget -O webmin-setup-repo.sh \
https://raw.githubusercontent.com/webmin/webmin/master/webmin-setup-repo.sh

yes | sh webmin-setup-repo.sh

apt install -y webmin --install-recommends

echo ">>> Redémarage"
reboot
