#!/bin/bash
# =============================================================================
# BOOCHAN V2 - Aprovisionamiento de Samba AD DC (Azure)
# =============================================================================
# Modulo: SOR - Sistemas Operativos en Red · 2.º SMR · IES Jorge Juan (Alicante)
# Profesor: Pedro Navarro Miralles
#
# USO:
#   sudo ./provision_boochan.sh
#   sudo ./provision_boochan.sh OTRODOMINIO OTRO.REALM OtraContrasena
#
# ANTES DE EJECUTARLO: leelo entero. Nunca ejecutes como root un script que no
# has leido. Aqui dentro hay comandos que borran ficheros del sistema y hacen
# inmutable /etc/resolv.conf.
# =============================================================================

set -euo pipefail   # Aborta al primer error. Ver nota al final del fichero.

DOMAIN_NAME=${1:-"BOOCHAN"}
REALM_NAME=${2:-"BOOCHAN.SPACE"}
ADMIN_PASS=${3:-"P@ssw0rd"}
DNS_FORWARDER="8.8.8.8"

echo "=== Despliegue del Reino: $REALM_NAME ==="

# --- 0. COMPROBACIONES PREVIAS --------------------------------------------
if [ "$EUID" -ne 0 ]; then
    echo "ERROR: ejecutalo con sudo."; exit 1
fi

FALTAN=""
for cmd in samba-tool chattr ip; do
    command -v "$cmd" >/dev/null 2>&1 || FALTAN="$FALTAN $cmd"
done
if [ -n "$FALTAN" ]; then
    echo "ERROR: faltan comandos:$FALTAN"
    echo "       Vuelve al Paso 2 de la Fase 2 e instala los paquetes."
    exit 1
fi

# Ubuntu 24.04+ reparte el AD DC en paquetes separados del paquete 'samba'.
for pkg in samba-ad-dc samba-ad-provision; do
    if ! dpkg -s "$pkg" >/dev/null 2>&1; then
        echo "ERROR: falta el paquete '$pkg', imprescindible para el dominio."
        echo "       Instalalo con: sudo apt install -y samba-ad-dc samba-ad-provision"
        exit 1
    fi
done

# --- IP del servidor -------------------------------------------------------
# Esta maquina tiene MAS DE UNA interfaz: la de Azure y el tunel WireGuard
# (wg0) de la Fase 3. Si no le decimos cual usar, samba-tool elige la primera
# que encuentra y el dominio se anunciaria en una IP que nadie puede alcanzar.
# Aqui se detecta la IP de Azure excluyendo el tunel y el loopback.
HOST_IP="${HOST_IP:-$(ip -4 -o addr show scope global | grep -vw wg0 | awk '{print $4}' | cut -d/ -f1 | head -1)}"

if [ -z "$HOST_IP" ]; then
    echo "ERROR: no he podido detectar la IP privada del servidor."
    echo "       Pasala a mano:  sudo HOST_IP=1.2.3.4 ./provision_boochan.sh"
    exit 1
fi

echo "[OK] Comprobaciones superadas. El dominio se anunciara en: $HOST_IP"
echo "     (si esa NO es la IP privada de tu servidor en Azure, aborta con Ctrl+C"
echo "      y relanza con:  sudo HOST_IP=la_correcta ./provision_boochan.sh )"
sleep 3

# --- 1. Aprovisionamiento del Dominio -------------------------------------
# ORDEN IMPORTANTE: esto va ANTES de tocar el DNS. Si el aprovisionamiento
# falla, el servidor conserva su resolucion de nombres y puedes seguir
# instalando paquetes para arreglarlo. Al reves, un fallo aqui te dejaria sin
# DNS y sin forma de instalar nada: encerrado fuera.
#
# samba-tool se NIEGA a aprovisionar si existe un smb.conf con 'server role =
# standalone server', que es justo el que crea el paquete 'samba' al
# instalarse. Hay que apartarlo: el provision genera el suyo.
# --use-rfc2307 es imprescindible: guarda UID/GID de Unix dentro de Active
# Directory. Sin esto, la Fase 5 (winbind) no puede funcionar.
echo "[1/4] Aprovisionando el dominio (2-3 minutos)..."
if [ -f /etc/samba/smb.conf ]; then
    mv /etc/samba/smb.conf "/etc/samba/smb.conf.bak-$(date +%s)"
fi

samba-tool domain provision \
 --server-role=dc \
 --use-rfc2307 \
 --dns-backend=SAMBA_INTERNAL \
 --realm="$REALM_NAME" \
 --domain="$DOMAIN_NAME" \
 --adminpass="$ADMIN_PASS" \
 --host-ip="$HOST_IP" \
 --option="dns forwarder = $DNS_FORWARDER"

# --- 2. Configuracion Kerberos --------------------------------------------
echo "[2/4] Configurando Kerberos..."
cp /var/lib/samba/private/krb5.conf /etc/krb5.conf

# --- 3. Activacion del Servidor AD DC -------------------------------------
# smbd, nmbd y winbind son los servicios del Samba "clasico" y ocupan los
# puertos que necesita el controlador de dominio. samba-ad-dc los sustituye a
# los tres. El stub de systemd-resolved se apaga aqui, justo antes de levantar
# Samba, para que su DNS interno pueda quedarse con el puerto 53.
echo "[3/4] Activando samba-ad-dc..."
sed -i 's/#DNSStubListener=yes/DNSStubListener=no/' /etc/systemd/resolved.conf
systemctl restart systemd-resolved
systemctl disable --now smbd nmbd winbind 2>/dev/null || true
systemctl unmask samba-ad-dc
systemctl enable --now samba-ad-dc

# --- 4. DNS Persistente: apuntar el servidor a si mismo --------------------
# Ultimo paso a proposito: ahora SI hay un servidor DNS escuchando en
# 127.0.0.1 (el de Samba). chattr +i lo deja inmutable para que el agente de
# red de Azure no lo sobrescriba en cada arranque. El 'chattr -i' inicial es
# lo que permite RELANZAR el script.
echo "[4/4] Fijando el DNS del servidor..."
chattr -i /etc/resolv.conf 2>/dev/null || true
rm -f /etc/resolv.conf
printf "nameserver 127.0.0.1\nsearch %s\n" "$REALM_NAME" > /etc/resolv.conf
chattr +i /etc/resolv.conf

# --- VERIFICACION FINAL ----------------------------------------------------
# Un script que dice "finalizado" sin comprobar nada es un script que miente.
echo ""
if systemctl is-active --quiet samba-ad-dc; then
    echo "=========================================================="
    echo " Despliegue de $DOMAIN_NAME finalizado CORRECTAMENTE."
    echo " Realm: $REALM_NAME   ·   IP anunciada: $HOST_IP"
    echo " Comprueba ahora:  sudo samba-tool domain level show"
    echo " Y que el dominio apunta bien:"
    echo "   host -t A $(hostname).$(echo "$REALM_NAME" | tr 'A-Z' 'a-z')"
    echo "   -> debe devolver $HOST_IP , NO la IP del tunel"
    echo "=========================================================="
else
    echo "!!! El servicio samba-ad-dc NO esta activo."
    echo "!!! Revisa:  sudo systemctl status samba-ad-dc"
    exit 1
fi

# =============================================================================
# NOTA sobre 'set -euo pipefail' (primera linea del script):
#   -e  aborta en cuanto un comando falla
#   -u  aborta si se usa una variable no definida
#   -o pipefail  detecta fallos dentro de una tuberia
# Sin esto, el script seguia adelante con todo roto y terminaba diciendo que
# habia ido bien. Un script de administracion debe PARAR cuando algo falla.
# =============================================================================
