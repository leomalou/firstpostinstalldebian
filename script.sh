#!/bin/bash

echo "=== Baseline CLI Debian - Post Install ==="

# Vérification root
if [ "$EUID" -ne 0 ]; then
  echo "Lance ce script en root."
  exit 1
fi

echo ">>> Mise à jour du système"
apt update && apt upgrade -y

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
# INSTALLATION DE WEBMIN
# =========================

echo ">>> Installation de Webmin"

# Sécurité : curl
if ! command -v curl &>/dev/null; then
  echo "curl absent, installation..."
  apt install -y curl
fi

curl -o webmin-setup-repo.sh \
https://raw.githubusercontent.com/webmin/webmin/master/webmin-setup-repo.sh

sh webmin-setup-repo.sh
apt install -y webmin --install-recommends -y

echo ">>> Webmin installé (https://IP:10000)"

echo ">>> Baseline terminée avec succès."
echo "Un redémarrage est conseillé."

