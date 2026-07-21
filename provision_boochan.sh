#!/bin/bash
# BOOCHAN V2 - Script Profesional de Aprovisionamiento Samba AD DC (Microsoft Azure)
# Este script automatiza la configuración de red persistente, el despliegue del dominio
# y la integración de Kerberos de forma desatendida.

# --- CONFIGURACIÓN ---
# Podrías pasar estos parámetros como variables de entorno si quieres mayor flexibilidad
DOMAIN_NAME=${1:-"BOOCHAN"}
REALM_NAME=${2:-"BOOCHAN.SPACE"}
ADMIN_PASS=${3:-"P@ssword2026!"}
DNS_FORWARDER="8.8.8.8"

echo "--- Iniciando el despliegue desatendido del Reino: $REALM_NAME ---"

# --- 1. Gestión DNS Persistente (Evitar que el servicio de red de AWS sobreescriba) ---
echo "Configurando DNS persistente..."
# Desactivamos systemd-resolved en el puerto 53 para que Samba pueda usarlo
sudo sed -i 's/#DNSStubListener=yes/DNSStubListener=no/' /etc/systemd/resolved.conf
sudo systemctl restart systemd-resolved

# Creamos el resolv.conf inmutable para asegurar que Samba AD DC sea siempre el DNS local
sudo rm -f /etc/resolv.conf
echo -e "nameserver 127.0.0.1\nsearch $REALM_NAME" | sudo tee /etc/resolv.conf
sudo chattr +i /etc/resolv.conf

# --- 2. Aprovisionamiento Automático (Desatendido) ---
echo "Ejecutando aprovisionamiento de Samba AD DC..."
# --use-rfc2307: Habilita el esquema para mapear UIDs de Linux con usuarios de Windows
# --dns-backend=SAMBA_INTERNAL: Usa el servidor DNS integrado de Samba
sudo samba-tool domain provision \
 --server-role=dc \
 --use-rfc2307 \
 --dns-backend=SAMBA_INTERNAL \
 --realm=$REALM_NAME \
 --domain=$DOMAIN_NAME \
 --adminpass=$ADMIN_PASS \
 --option="dns forwarder = $DNS_FORWARDER"

# --- 3. Configuración Kerberos (Integración del Sistema) ---
echo "Configurando Kerberos..."
# Copiamos la configuración generada por Samba al archivo oficial del sistema
sudo cp /var/lib/samba/private/krb5.conf /etc/krb5.conf

# --- 4. Activación del Servidor AD DC ---
echo "Activando el servicio Samba AD DC..."
sudo systemctl disable --now smbd nmbd winbind
sudo systemctl unmask samba-ad-dc
sudo systemctl enable --now samba-ad-dc

echo "--- Despliegue de $DOMAIN_NAME finalizado. ---"
echo "Verificación: Ejecuta 'samba-tool domain level show' para confirmar el dominio."
