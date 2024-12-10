#!/bin/bash
IP_FILE="ips"
USER="domain/user"
PASSWORD='password'

if [ ! -f $IP_FILE ]; then
    echo "Le fichier $IP_FILE n'existe pas. Veuillez le vérifier."
    exit 1
fi

echo "Début du test pour les IPs listées dans $IP_FILE..."

while read -r IP; do
    if [[ -z "$IP" ]]; then
        continue
    fi

    echo "Testing IP: $IP"

    smbclient -L $IP -U $USER%$PASSWORD | grep 'Disk' | awk '{print $1}' > shares.txt

    if [ ! -s shares.txt ]; then
        echo "Aucun partage disponible ou connexion échouée pour $IP."
        continue
    fi

    while read -r SHARE; do
        echo "  Trying to connect to $IP/$SHARE"
        smbclient //$IP/$SHARE -U $USER%$PASSWORD -c "ls" >/dev/null 2>&1
        if [ $? -eq 0 ]; then
            echo "    Access SUCCESSFUL: $IP/$SHARE"
        else
            echo "    Access DENIED: $IP/$SHARE"
        fi
    done < shares.txt

done < $IP_FILE

echo "Tous les tests sont terminés."
