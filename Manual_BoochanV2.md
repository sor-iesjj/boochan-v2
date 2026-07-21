# 🚀 BoochanV2 — Infraestructura de Servidores Cloud sobre Azure (Ubuntu Server + Samba AD DC)

> **Módulo:** Sistemas Operativos en Red (SOR) · 2.º Curso SMR
> **Profesor:** Pedro Navarro Miralles · IES Jorge Juan (Alicante)
> **Correo:** p.navarromiralles2@edu.gva.es
> **Entorno:** Microsoft Azure (IaaS) — versión original del proyecto Boochan en la nube
> **RA cubiertos:** RA.01, RA.02, RA.03, RA.04, RA.05, RA.06
> **⏱️ Tiempo estimado total:** ~13-14 horas repartidas en 9 sesiones

---

## ¿Qué es este proyecto?

BoochanV2 es un itinerario práctico de **8 fases + auditoría final** en el que el alumno construye, desde cero y en la nube de **Microsoft Azure**, una infraestructura profesional completa: un servidor **Ubuntu Server** con **Controlador de Dominio (Samba AD DC)**, **VPN WireGuard**, **cuotas de disco (Loop Devices)**, **permisos avanzados (ACL + ABE)** y un **cliente Windows 11** integrado en el dominio a través de un túnel cifrado.

Es la versión **cloud original** del proyecto Boochan, desplegada sobre Azure IaaS (Infraestructura como Servicio): en lugar de instalar Ubuntu en una máquina física del aula, se alquila un servidor virtual en los centros de datos de Microsoft y se administra "sin cabeza" (headless), gestionando la seguridad perimetral desde una consola web.

---

## Relación con las otras versiones del proyecto Boochan

El proyecto Boochan existe en varias versiones equivalentes que enseñan **exactamente los mismos conceptos** de administración de sistemas en red, cambiando solo dónde vive el servidor y qué implementación de directorio se usa:

| Entorno | Ubuntu + Samba AD DC | Windows Server 2025 + AD DS nativo |
|---|---|---|
| VM local | BoochanV1 (VirtualBox) | BoochanV1.1 (Hyper-V) |
| **Azure** | **BoochanV2 (esta)** | BoochanV2.1 |
| AWS | BoochanV3 | BoochanV3.1 |

BoochanV2 es la rama **Azure + Linux** — la versión de la que parten todas las demás. BoochanV3 traslada el mismo itinerario a AWS; BoochanV2.1 lo reimplementa con Windows Server 2025 y AD DS nativo sobre la misma Azure.

---

## ⚠️ Antes de empezar: requisitos del proyecto (LÉEME)

- **Cuenta de Azure gestionada por el profesor**, con las credenciales de acceso al Azure Portal.
- Una VM `Standard_B2s` (2 vCPU, 4 GB RAM) con **Ubuntu Server 22.04 LTS**, protegida por un **Network Security Group (NSG)** que solo abre los puertos necesarios.
- **Windows 11 (PC físico del aula)** como cliente, necesario a partir de la Fase 8 — es el propio ordenador del alumno unido al dominio por VPN, no una máquina virtual.
- **WireGuard** instalado tanto en el servidor como en el PC del aula, desde la Fase 3.
- **Apagar o desasignar la VM** al terminar cada sesión si el profesor lo indica, para no generar coste innecesario.

El detalle completo está al inicio de la **[Fase 1](Fases/Fase_1.md)**.

---

## 🗺️ Índice de fases

| Fase | Título | Concepto Azure / Linux clave |
|------|--------|------------------------------|
| [1](Fases/Fase_1.md) | Infraestructura Cloud (Azure IaaS) | VM `Standard_B2s`, NSG, SSH puerto 2222 |
| [2](Fases/Fase_2.md) | Purga y Preparación del Entorno | Limpieza de Samba preinstalado, FQDN, `/etc/hosts` |
| [3](Fases/Fase_3.md) | Conectividad VPN (WireGuard) | Túnel cifrado servidor↔aula, cierre del puerto 2222 (Zero Trust) |
| [4](Fases/Fase_4.md) | Aprovisionamiento del Dominio (Samba AD DC) | `provision_boochan.sh`, Active Directory, Kerberos, DNS interno |
| [5](Fases/Fase_5.md) | Gestión de Identidades (Usuarios y Grupos) | winbind, mapeo UID/GID, `samba-tool` |
| [6](Fases/Fase_6.md) | Almacenamiento Virtual (Cuotas) | Loop Devices (`.img`), `fstab` |
| [7](Fases/Fase_7.md) | Seguridad Avanzada (ACLs y ABE) | `setfacl`, Access Based Enumeration (carpetas invisibles) |
| [8](Fases/Fase_8.md) | Integración del Cliente (Windows 11) | PC físico del aula unido al dominio, mapeo de unidades |
| [Final](Fases/Auditoria_Final.md) | Auditoría Final y Hardening | Zero Trust, restricción de origen en el NSG |

### Resumen de cada fase

**[Fase 1 — Infraestructura Cloud (Azure IaaS)](Fases/Fase_1.md):** se despliega la VM `Standard_B2s` con Ubuntu Server 22.04 LTS y se protege con un NSG que abre solo los puertos necesarios (SSH en el 2222 en vez del 22 para despistar a los bots, WireGuard, y los puertos de Active Directory). Se fija el dominio del proyecto: `BOOCHAN` / `BOOCHAN.SPACE`.

**[Fase 2 — Purga y Preparación del Entorno](Fases/Fase_2.md):** se elimina el Samba preinstalado (para liberar el puerto 445), se instalan las dependencias (Samba, Kerberos, winbind, WireGuard…) y se fija el FQDN del servidor en `/etc/hosts`.

**[Fase 3 — Conectividad VPN (WireGuard)](Fases/Fase_3.md):** se construye un túnel cifrado punto a punto entre el servidor en Azure y el PC del aula, sobre Internet real. Al final se aplica Zero Trust cerrando el SSH público (2222) y dejándolo accesible solo por la VPN.

**[Fase 4 — Aprovisionamiento del Dominio (Samba AD DC)](Fases/Fase_4.md):** con el script `provision_boochan.sh` se promociona el servidor a Controlador de Dominio (Samba AD DC): base de datos LDAP, Kerberos y DNS interno. El script blinda el `/etc/resolv.conf` con `chattr +i` para que Azure no lo sobrescriba.

**[Fase 5 — Gestión de Identidades (Usuarios y Grupos)](Fases/Fase_5.md):** se crean usuarios y grupos con `samba-tool`, y se mapean sus identidades de Windows (SID) a identidades de Linux (UID/GID) mediante winbind, para que el sistema de ficheros aplique permisos reales.

**[Fase 6 — Almacenamiento Virtual (Cuotas)](Fases/Fase_6.md):** se limitan físicamente las carpetas con **Loop Devices** — archivos `.img` formateados como discos reales y montados vía `/etc/fstab` — para que ningún usuario pueda llenar el servidor.

**[Fase 7 — Seguridad Avanzada (ACLs y ABE)](Fases/Fase_7.md):** se combinan permisos de Linux (`setfacl`, el "cerrojo real") con **Access Based Enumeration** de Samba (la "capa de invisibilidad": quien no tiene permiso ni siquiera ve la carpeta en el explorador).

**[Fase 8 — Integración del Cliente (Windows 11)](Fases/Fase_8.md):** el **PC físico del aula** activa el túnel WireGuard, sincroniza su reloj (crítico para Kerberos), se une al dominio `BOOCHAN.SPACE` y mapea las carpetas compartidas — demostrando que un sistema propietario (Windows) se autentica contra un servidor libre (Linux/Samba).

**[Auditoría Final — Hardening](Fases/Auditoria_Final.md):** cierre de seguridad con el principio Zero Trust — se restringe el origen de las reglas del NSG a la red de la VPN, dejando el servidor invisible desde Internet salvo el propio puerto del túnel WireGuard.

---

## 📊 Datos clave del proyecto

| Concepto | Valor en BoochanV2 |
| :--- | :--- |
| **Nombre NetBIOS** | `BOOCHAN` |
| **Realm (dominio completo)** | `BOOCHAN.SPACE` |
| **VM del servidor** | `Standard_B2s` (2 vCPU, 4 GB RAM), Ubuntu Server 22.04 LTS |
| **IP privada del servidor (Azure)** | `10.0.0.1` |
| **Red del túnel VPN (WireGuard)** | `10.0.0.0/24` (coincide con el rango de Azure a propósito) |
| **Acceso / credenciales** | Usuario `boochan` + contraseña, SSH por el puerto `2222` |
| **Firewall perimetral** | Network Security Group (NSG) de Azure |
| **Sistema operativo servidor** | Ubuntu Server 22.04 LTS (headless) |
| **Sistema operativo cliente** | Windows 11 (PC físico del aula) |
| **Plataforma / coste** | Microsoft Azure (cuenta gestionada por el profesor) |

---

## 📂 Estructura de la carpeta

```
BoochanV2/
├── Manual_BoochanV2.md           ← este documento (punto de entrada)
├── provision_boochan.sh          ← script de provisión del dominio (Fase 4)
├── Fases/
│   ├── Fase_1.md … Fase_8.md     ← las 8 fases del itinerario
│   └── Auditoria_Final.md        ← cierre de seguridad (hardening del NSG)
└── 99_Recursos/
    ├── Diccionario_Comandos_Sistema.md    ← comandos de Linux / Samba / WireGuard
    ├── Guía_Editor_Nano.md                ← cómo editar ficheros con nano
    └── Guía_Errores_y_Resolución.md       ← catálogo de errores por fase
```

---

## 🧭 Recomendación de uso

1. Lee este manual y la advertencia de requisitos (cuenta Azure gestionada por el profesor, Windows 11 del aula, WireGuard).
2. Sigue las fases **en orden** — son dependientes entre sí (las Fases 4, 5, 7 y 8 son secuenciales; la Fase 8 requiere las Fases 1-7 completas y un PC físico del aula disponible).
3. Si algo falla, antes de bloquearte consulta **[99_Recursos/Guía_Errores_y_Resolución.md](99_Recursos/Guía_Errores_y_Resolución.md)**, organizada por fase.
4. Para repasar comandos de Linux/Samba/WireGuard consulta **[99_Recursos/Diccionario_Comandos_Sistema.md](99_Recursos/Diccionario_Comandos_Sistema.md)**; para editar ficheros, **[99_Recursos/Guía_Editor_Nano.md](99_Recursos/Guía_Editor_Nano.md)**.
5. Al terminar cada sesión, si el profesor lo indica, desasigna la VM desde el Portal para no generar coste innecesario.
