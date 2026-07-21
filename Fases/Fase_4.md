## 👑 Fase 4: Aprovisionamiento del Dominio (Samba AD DC)

### Infraestructura de Servidores Cloud

> **[Módulo: SOR — Sistemas Operativos en Red]**
> **[U.T. 10: Integración de Sistemas Operativos - Servidor de Dominio]**
> **[RA.03]** Realiza tareas de gestión sobre dominios identificando necesidades y aplicando herramientas.
>
> **Profesor:** Pedro Navarro Miralles  
> **Correo:** p.navarromiralles2@edu.gva.es  
> **Centro:** IES Jorge Juan (ALICANTE)
>
> **⏱️ Tiempo estimado:** ~2,5 horas (teoría + práctica + retos + troubleshooting)  
> **Requisitos:** 4-8 GB RAM | Azure Portal | Git | Samba disponible

---

### 🎯 ¿Dónde Estamos?

> [!info] Vienes de Fase 3
> Tienes un servidor con identidad de dominio (UbuntuServer.BOOCHAN.SPACE), accesible de forma segura a través de un túnel VPN desde el aula. Ahora necesitas darle la funcionalidad de un verdadero **Controlador de Dominio** — el "cerebro" que gestiona usuarios, grupos, autenticación y autorización.

> [!warning] El Problema
> Sin un dominio, Windows 11 en el aula es un equipo aislado. Los usuarios se loguean localmente (usuario/contraseña guardados en el PC). No hay forma centralizada de gestionar identidades, no hay Single Sign-On, no hay políticas de grupo. Si necesitas cambiar la contraseña de un usuario, debes hacerlo en cada PC manualmente. Además, Kerberos (el protocolo de seguridad profesional) requiere un dominio para funcionar.

> [!success] Objetivo de esta Fase
> Provisionar **Samba AD DC** (Active Directory Domain Controller) en el servidor. Esto creará el dominio BOOCHAN.SPACE como un "reino" Kerberos con servicios interdependientes: LDAP (directorio), DNS interno (registros SRV), Kerberos (autenticación), y replicación. Desde ahora, los usuarios se autenticarán contra el dominio, no contra máquinas individuales.

> [!tip] Hoja de Ruta
> 1. Abrir 13 puertos en Azure NSG (Kerberos, DNS, LDAP, SMB, RPC, NTP — todo lo que AD necesita)
> 2. Ejecutar el script `provision_boochan.sh` que automatiza la creación del dominio (tarda 2-3 minutos)
> 3. Verificar que el servicio `samba-ad-dc` está activo: `sudo systemctl status samba-ad-dc`
> 4. Comprobar que el DNS interno apunta a 127.0.0.1 (no a Azure): `cat /etc/resolv.conf`
> 5. Hacer inmutable `/etc/resolv.conf` con `chattr +i` para que Azure no lo rompa en reinicios
> 6. Validar que Kerberos funciona: `nslookup _kerberos._tcp.BOOCHAN.SPACE 127.0.0.1`
> 7. Listar usuarios creados automáticamente: `samba-tool user list` (verás Administrator, krbtgt, etc.)
>
> **Resultado Final:** Dominio BOOCHAN.SPACE completamente provisionado y operativo. El servidor es ahora un verdadero Controlador de Dominio profesional.
> **Siguiente:** Fase 5 (Usuarios) — crearás usuarios del dominio (user1, user2) con mapeados correctos a Linux (UIDs/GIDs).

---

### 📚 Fundamento Teórico

> [!abstract] 1. El "Cerebro" de la Red: Active Directory (AD)
> Estamos creando el **Active Directory**. Este es el "Cerebro" que gestiona la base de datos de todos los objetos de la red: usuarios, grupos y ordenadores. Samba AD DC emula tres servicios vitales para que esto funcione:
> *   **LDAP:** El protocolo para consultar la base de datos de usuarios.
> *   **Kerberos:** El sistema de "tickets" de seguridad (como un pase VIP de un festival).
> *   **DNS Interno:** Samba gestiona sus propios registros SRV que indican dónde están los servicios de red.

> [!important] 2. Inmutabilidad y Persistencia
> Azure intenta gestionar el DNS por ti automáticamente. Sin embargo, para que el Dominio funcione, el servidor debe apuntar a **sí mismo** para resolver nombres. 
> Al usar el comando `chattr +i` sobre el archivo `/etc/resolv.conf`, lo hacemos **inmutable** (imposible de borrar o cambiar), evitando que Microsoft "rompa" nuestra red local al reiniciar.

### 📖 Diccionario de Conceptos Clave

> [!quote] Terminología de Dominio
> - **Reino (Realm):** El nombre de dominio completo (ej. `BOOCHAN.SPACE`). Siempre se escribe en **MAYÚSCULAS** para que Kerberos lo entienda.
> - **Provisionamiento:** El acto de generar la base de datos del dominio desde cero.
> - **SRV Record:** Un registro DNS especial que indica qué servidor ofrece un servicio específico (ej. "el servidor de tickets está en esta IP").
> - **chattr +i:** El "cemento armado" de Linux. Hace que un archivo no se pueda modificar ni por el administrador.

---

### 🔓 Apertura de Puertos (NSG de Azure)

> [!example] Al empezar: abre los puertos del dominio
> Active Directory es un ecosistema de servicios que se hablan entre sí. Antes de provisionar el dominio, todos sus puertos deben estar abiertos en Azure — si falta uno, los clientes Windows no podrán autenticarse ni resolver nombres.
>
> 1. Entra en **portal.azure.com** → tu VM → **`Configuración de red`** → haz clic en el nombre de tu NSG.
> 2. En el menú izquierdo, haz clic en **`Reglas de seguridad de entrada`**.
> 3. Pulsa **`+ Agregar`** y, para **cada fila** de la tabla siguiente, rellena el formulario así:
>    - **Origen:** `Any`
>    - **Intervalos de puertos de destino:** el número de la columna "Puerto"
>    - **Protocolo:** el de la columna "Protocolo"
>    - **Acción:** `Permitir`
>    - **Prioridad:** el número de la columna "Prioridad"
>    - **Nombre:** el texto de la columna "Nombre"
> 4. Pulsa **`Agregar`** después de cada regla:
>
> | Prioridad | Nombre | Puerto | Protocolo | Para qué sirve ahora |
> | :--- | :--- | :--- | :--- | :--- |
> | **410** | Kerberos_TCP | 88 | TCP | Emite los "tickets" de seguridad que identifican a cada usuario del dominio. |
> | **411** | Kerberos_UDP | 88 | UDP | Ídem por UDP — Windows usa ambos según el tipo de petición. |
> | **412** | DNS_TCP | 53 | TCP | Resuelve los nombres del dominio (ej. `BOOCHAN.SPACE`). |
> | **413** | DNS_UDP | 53 | UDP | Ídem por UDP — la mayoría de consultas DNS viajan por UDP. |
> | **414** | RPC_Endpoint | 135 | TCP | Punto de entrada para las llamadas a procedimiento remoto de Windows. |
> | **415** | LDAP_TCP | 389 | TCP | Permite consultar el directorio de usuarios y grupos del dominio. |
> | **416** | LDAP_UDP | 389 | UDP | Ídem por UDP. |
> | **417** | LDAPS | 636 | TCP | Versión cifrada de LDAP — protege las consultas de usuarios en tránsito. |
> | **418** | SMB_Files | 445 | TCP | Acceso a las carpetas compartidas del servidor (Samba). |
> | **419** | RPC_Dinamico | 49152-65535 | TCP | Rango de puertos que Active Directory negocia dinámicamente para comunicarse. |
> | **420** | Kerberos_Pass_TCP | 464 | TCP | Gestión de cambios de contraseña de los usuarios del dominio. |
> | **421** | Kerberos_Pass_UDP | 464 | UDP | Ídem por UDP. |
> | **422** | NTP_Time | 123 | UDP | Sincronización horaria del servidor — Kerberos falla si el reloj difiere más de 5 minutos. |
>
> > [!info] 💡 ¿Por qué tantos puertos de golpe?
> > En las fases anteriores abriste solo lo imprescindible para no exponer el servidor innecesariamente. Active Directory es diferente: es un ecosistema de servicios interdependientes. DNS encuentra el servidor, Kerberos autentica al usuario, LDAP consulta su perfil y RPC coordina todo el proceso. Si falta uno, la cadena se rompe. Esta es la única fase del proyecto donde abrirás tantos puertos a la vez. A partir de la Fase 5 no necesitarás añadir ninguno más.

---

### 🛠️ Procedimiento Práctico (BoochanV2)

> [!example] Paso 1: Descarga del Proyecto y Ejecución del Script
> Para evitar errores humanos, usaremos el script `provision_boochan.sh`. Primero, descargamos el proyecto completo desde el repositorio usando `git`:
>
> > [!info] 📚 Diccionario de Comandos: Consulta el [[Diccionario_Comandos_Sistema]] para entender al detalle cómo funcionan los comandos administrativos que usaremos aquí.
>
> ```bash
> # Instala git si no lo tienes aún
> sudo apt install git -y
> # Descarga el repositorio del proyecto en la carpeta /opt/boochan
> git clone URL_DEL_REPOSITORIO /opt/boochan
> # Entra en la carpeta descargada
> cd /opt/boochan
> # Dale permiso de ejecución al script y ejecútalo
> sudo chmod +x provision_boochan.sh
> sudo ./provision_boochan.sh
> ```
> > [!caution] ⚠️ Antes de ejecutar: pide la URL al profesor
> > El texto `URL_DEL_REPOSITORIO` es un marcador de posición. **Sustitúyelo** por la URL real que te proporcione tu profesor antes de pulsar Enter. Si ejecutas el comando con ese texto literal, git devolverá un error inmediato.
>
> El script tardará **2-3 minutos**. Verás mensajes de progreso en pantalla.
>
> > [!tip] 💡 El script escribe mucho en pantalla — ¿cómo sé si va bien?
> > Es normal ver líneas de color amarillo o incluso algún aviso en rojo durante el proceso: son mensajes informativos de Samba, no errores reales. Solo hay que preocuparse si el script **se detiene antes de terminar** sin mostrar el mensaje final. La línea que confirma que todo ha ido bien es:
> > ```
> > Despliegue de BOOCHAN finalizado
> > ```
> > Si no aparece esa línea, el script falló. Revisa la tabla de troubleshooting al final de esta fase.
>
> > [!tip] 💡 ¿Qué hace este comando?
> > - **`git clone`:** Descarga una copia completa del proyecto desde internet a tu servidor, igual que descargar un ZIP pero de forma más profesional.
> > - **`chmod +x`:** En Linux, los archivos descargados no "tienen permiso" para ejecutarse por seguridad. Este comando le pone la etiqueta de **ejecutable**.
> > - **El punto y la barra (`./`):** Le dice a Linux: "Busca este archivo **aquí mismo**, en esta carpeta". Sin el `./`, Linux buscaría el comando en las carpetas del sistema y no lo encontraría.
> > - **Los valores por defecto del script:** El script ya viene configurado con los valores correctos del proyecto (`BOOCHAN.SPACE`, contraseña `P@ssword2026!`). No necesitas modificar nada salvo que tu profesor indique lo contrario.

> [!example] Paso 2: Verificación de Servicios
> Una vez finalizado el script, debemos comprobar que el "corazón" del dominio está latiendo:
> ```bash
> # Comprobar que el servicio está activo y corriendo
> sudo systemctl status samba-ad-dc
> ```

> [!example] Paso 3: Verificación del DNS
> Es vital confirmar que el servidor se mira a sí mismo para resolver nombres de red:
> ```bash
> # Debe devolver: nameserver 127.0.0.1
> cat /etc/resolv.conf
> ```

---

### 🚩 Resolución de Problemas y Evaluación

> [!bug] Troubleshooting (¿El dominio no nace?)
> | Problema | Causa Probable | Solución Sugerida |
> | :--- | :--- | :--- |
> | Error `Realm not found`. | El archivo `/etc/krb5.conf` no está bien configurado. | Copia el generado por Samba: `sudo cp /var/lib/samba/private/krb5.conf /etc/krb5.conf`. |
> | No resuelve al 127.0.0.1. | `systemd-resolved` está secuestrando el DNS por un error del script. | Apágalo con `sudo systemctl disable systemd-resolved --now`, luego destruye el enlace `sudo rm /etc/resolv.conf` e inyecta la IP: `echo "nameserver 127.0.0.1" | sudo tee /etc/resolv.conf`. Por último, bloquéalo de nuevo con `sudo chattr +i /etc/resolv.conf`. |

> [!help] Preguntas Críticas (Autoevaluación)
> 1. ¿Por qué es fundamental que el servidor DNS del dominio sea el propio servidor (127.0.0.1)?
> 2. ¿Qué es un "ticket" de Kerberos y por qué evita enviar contraseñas por la red constantemente?
> 3. ¿Qué pasaría si el atributo de inmutabilidad (`+i`) no estuviera activo en el `resolv.conf` tras reiniciar en Azure?
> 4. 🔬 **Reto práctico:** Ejecuta `nslookup _kerberos._tcp.BOOCHAN.SPACE 127.0.0.1` en el servidor. Si el dominio está bien provisionado, ¿qué IP debería devolver? Si no devuelve nada, ¿qué componente del sistema está fallando?
> 5. 🔬 **Reto práctico:** Ejecuta `samba-tool user list` en el servidor. ¿Qué usuarios ves, siendo que tú no has creado ninguno todavía? Localiza el usuario que empieza por `krbtgt` — busca en internet para qué sirve ese usuario en Kerberos y explícalo con tus palabras. Compara además la RAM libre actual con la que anotaste al final de la Fase 1.

---

> [!caution] 🛑 Auditoría y Evaluación (RA.03)
> **Peligro Crítico:** Si el DNS vuelve a apuntar a Azure en lugar de a 127.0.0.1, los ordenadores dirán "No se encuentra el dominio" y nadie podrá iniciar sesión.

> [!success] 🏁 Punto de Control (Antes de seguir)
> Antes de ejecutar las verificaciones, instala las herramientas de diagnóstico DNS (no vienen preinstaladas en Ubuntu Server):
> ```bash
> sudo apt install dnsutils -y
> ```
> - [ ] ¿Responde `samba-tool domain level show` sin errores?
> - [ ] ¿El comando `nslookup _kerberos._tcp.BOOCHAN.SPACE` devuelve la IP correcta?