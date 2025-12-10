#!/bin/bash

echo "=== Baseline CLI Debian - Post Install ==="

# Sécurité : vérifier qu'on est root
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

echo ">>> Installation couche NetBIOS (winbind + samba)"
apt install -y winbind samba

echo ">>> Configuration de nsswitch (ajout de wins)"
if grep -q "^hosts:.*wins" /etc/nsswitch.conf; then
  echo "wins déjà présent dans nsswitch.conf"
else
  sed -i 's/^hosts:.*/& wins/' /etc/nsswitch.conf
  echo "wins ajouté à la ligne hosts"
fi

echo ">>> Personnalisation du bash root"
BASHRC="/root/.bashrc"

# Décommenter les lignes 9 à 13
sed -i '10,14 s/^#//' "$BASHRC"

echo ">>> Baseline terminée avec succès."
echo "Redémarre la machine pour appliquer proprement les changements."
