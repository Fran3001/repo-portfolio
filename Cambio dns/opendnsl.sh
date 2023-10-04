#!/bin/bash

# Verifica si se está ejecutando como root
if [[ $EUID -ne 0 ]]; then
   echo "Este script debe ejecutarse como root" 
   exit 1
fi

# Define las DNS
DNS1="208.67.222.222"
DNS2="208.67.220.220"
DNS3="8.8.8.8"

# Obtiene el nombre de la red Wi-Fi actual
SSID=$(iwgetid -r)

# Verifica si hay una conexión Ethernet activa
if [[ -n $(ip link | grep 'state UP' | grep 'eth') ]]; then
    echo "Tienes una conexión Ethernet activa."
    
    # Encuentra la interfaz Ethernet activa
    ETH_INTERFACE=$(ip link | grep 'state UP' | grep -E 'enp[0-9]+s[0-9]+|eth[0-9]+' | awk -F: '{print $2}' | sed 's/^[[:space:]]*//')
    
    # Configura las DNS para la interfaz Ethernet encontrada
    nmcli con mod "$ETH_INTERFACE" ipv4.dns "$DNS1 $DNS2 $DNS3"
else
    # Verifica si se encontró un nombre de red Wi-Fi
    if [[ -n "$SSID" ]]; then
        echo "Conectado a la red Wi-Fi: $SSID"
        # Configura las DNS para la conexión Wi-Fi actual
        nmcli con mod "$SSID" ipv4.dns "$DNS1 $DNS2 $DNS3"
    else
        echo "No se encontró una conexión Ethernet activa ni una red Wi-Fi activa."
        exit 1
    fi
fi

# Reinicia NetworkManager para aplicar los cambios
systemctl restart NetworkManager

sleep 4 # Para darle tiempo a la red a conectarse de nuevo

# Muestra la configuración DNS actual
echo "Configuración DNS actual:"
nmcli dev show | grep 'IP4.DNS'

