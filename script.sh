#!/bin/bash

echo "=== Baseline CLI Debian - Post Install ==="

# Vérification root
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

# Détection interface principale (non loopback)
IFACE=$(ip -o link show | awk -F': ' '{print $2}' | grep -v lo | head -n 1)
echo "Interface principale détectée : $IFACE"

# =========================
# MISE À JOUR
# =========================
echo ">>> Mise à jour du système"
apt update && apt upgrade -y

# =========================
# INSTALLATION OUTILS
# =========================
echo ">>> Installation des outils de base"
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
lynx

echo ">>> Mise à jour de la base locate"
updatedb

echo ">>> Installation couche NetBIOS"
apt install -y winbind samba

echo ">>> Configuration nsswitch (wins)"
if grep -q "^hosts:.*wins" /etc/nsswitch.conf; then
  echo "wins déjà présent"
else
  sed -i 's/^hosts:.*/& wins/' /etc/nsswitch.conf
  echo "wins ajouté"
fi

echo ">>> Personnalisation du bash root"
sed -i '10,14 s/^#//' /root/.bashrc

# =========================
# CONFIG RESEAU STATIQUE
# =========================
echo ">>> Configuration IP statique pour $IFACE"

# Sauvegarde
cp /etc/network/interfaces /etc/network/interfaces.bak

cat > /etc/network/interfaces <<EOF
auto lo
iface lo inet loopback

auto $IFACE
iface $IFACE inet static
    address $IP_ADDR
    netmask $NETMASK
    gateway $GATEWAY
    dns-nameservers $DNS1 $DNS2 $DNS3
    dns-search $DOMAIN
EOF

# Redémarrage du réseau
systemctl restart networking

# =========================
# CONFIG RESOLV (systemd-resolved)
# =========================
echo ">>> Configuration DNS sans search LAN"
if systemctl is-active --quiet systemd-resolved; then
    systemctl restart systemd-resolved
fi

# =========================
# INSTALLATION WEBMIN
# =========================
echo ">>> Installation de Webmin"

# Installer les dépendances pour Webmin
apt install -y wget apt-transport-https software-properties-common gnupg

# Télécharger et exécuter le script officiel
wget -O /tmp/webmin-setup-repo.sh \
https://raw.githubusercontent.com/webmin/webmin/master/webmin-setup-repo.sh
sh /tmp/webmin-setup-repo.sh

# Mettre à jour les dépôts pour prendre en compte Webmin
apt update

# Installer Webmin
apt install -y webmin

echo ">>> Webmin installé : https://$IP_ADDR:10000"

echo ">>> Baseline terminée avec succès."
echo "Redémarrage conseillé pour appliquer toutes les modifications."
