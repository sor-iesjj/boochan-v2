# 🚨 Guía de Errores y Resolución — Proyecto BoochanV2

> [!info] Cómo usar esta guía
> Este documento recoge todos los errores conocidos organizados por fase. Cada error tiene un código único (`Fase.Número`). Si algo no funciona, localiza la fase en la que estás, busca el error que más se parece a lo que ves en pantalla y sigue el procedimiento paso a paso.

---

## Fase 1 — Infraestructura Azure

---

### Error 1.1 — Azure rechaza una regla del NSG por prioridad duplicada

> [!bug] Cuándo se produce
> Al crear las reglas del cortafuegos (NSG), cuando intentas añadir la segunda regla de un protocolo que necesita TCP y UDP usando el mismo número de prioridad que la primera. Azure no permite dos reglas con el mismo número.

> [!warning] ¿Hay que preocuparse?
> No es grave, pero la regla no se guardará y el puerto quedará sin abrir, lo que causará fallos silenciosos en fases posteriores.

> [!example] Resolución
> 1. Las reglas que necesitan TCP y UDP deben crearse **dos veces**.
> 2. Usa prioridades **consecutivas**: por ejemplo, `410` para TCP y `411` para UDP.
> 3. Añade `_TCP` y `_UDP` al nombre para distinguirlas (por ejemplo: `Kerberos_Auth_TCP` y `Kerberos_Auth_UDP`).
> 4. Si ya creaste una con prioridad duplicada, elimínala y vuelve a crearla con el número correcto.

---

### Error 1.2 — Pérdida total de acceso SSH tras borrar el puerto 22

> [!bug] Cuándo se produce
> Si borras la regla del puerto 22 del NSG de Azure antes de que la VPN esté funcionando y el servidor esté escuchando en el puerto 2222.

> [!caution] ¿Hay que preocuparse?
> **Sí.** Quedas completamente fuera de tu servidor. La conexión SSH no funciona y no hay forma directa de volver a entrar.

> [!example] Resolución — Acceso por Consola de Serie de Azure
> 1. Entra en el portal de Azure ([portal.azure.com](https://portal.azure.com)).
> 2. Localiza tu máquina virtual `UbuntuServer`.
> 3. En el menú izquierdo, busca **"Consola de serie"** (sección "Soporte y solución de problemas").
> 4. Pulsa `Enter` para activar el prompt. Inicia sesión con `boochan` y `P@ssw0rd.SOR.2026`.
> 5. Vuelve al NSG de Azure y añade de nuevo la regla del puerto 22 (TCP, acción Permitir).
> 6. Ya puedes reconectarte por SSH normalmente.
>
> El puerto 22 solo debe borrarse cuando la VPN esté activa y hayas verificado que el acceso por el puerto 2222 funciona.

---

### Error 1.3 — La auditoría de cambio SSH al puerto 2222 no se ejecutó

> [!bug] Cuándo se produce
> Al llegar a fases avanzadas sin haber realizado la auditoría del final de la Fase 1: cambiar el puerto en `/etc/ssh/sshd_config` y eliminar la regla del puerto 22 del NSG.

> [!warning] ¿Hay que preocuparse?
> No bloquea el proyecto, pero el servidor queda expuesto a robots de Internet que atacan el puerto 22 de forma automática y continua.

> [!example] Resolución
> Ejecuta la auditoría en cualquier momento mientras la VPN esté activa:
> 1. Conéctate al servidor por el puerto 22 (aún activo):
>    ```bash
>    ssh boochan@TU_IP_PUBLICA
>    ```
> 2. Edita la configuración de SSH:
>    ```bash
>    sudo nano /etc/ssh/sshd_config
>    ```
> 3. Localiza la línea `#Port 22` (usa `Ctrl + W` y escribe `Port` para buscarla). Elimina el `#` y cambia `22` por `2222`.
> 4. Guarda (`Ctrl + O`, `Enter`, `Ctrl + X`) y reinicia el servicio:
>    ```bash
>    sudo systemctl restart ssh
>    ```
> 5. **Sin cerrar esta sesión**, abre un segundo terminal y verifica el acceso nuevo:
>    ```bash
>    ssh -p 2222 boochan@10.0.0.1
>    ```
> 6. Si el segundo terminal conecta correctamente, ya puedes eliminar la regla del puerto 22 en el NSG de Azure.

---

## Fase 2 — Purga y Preparación del Entorno

---

### Error 2.1 — El comando `apt install` se detiene con un error a mitad

> [!bug] Cuándo se produce
> Durante la instalación del Paso 2, si hay un problema de red momentáneo, un nombre de paquete incorrecto o espacio en disco insuficiente. El terminal muestra texto en rojo y el proceso se detiene sin completarse.

> [!warning] ¿Hay que preocuparse?
> No es grave si se actúa correctamente. Continuar con paquetes a medias instalados sí puede causar problemas difíciles de diagnosticar más adelante.

> [!example] Resolución
> 1. Repara los paquetes que quedaron a medias:
>    ```bash
>    sudo apt --fix-broken install -y
>    ```
> 2. Actualiza la lista de paquetes disponibles:
>    ```bash
>    sudo apt update
>    ```
> 3. Vuelve a ejecutar el comando de instalación completo. No pasa nada por repetirlo; `apt` detecta lo que ya está instalado y solo instala lo que falta:
>    ```bash
>    sudo apt install acl attr samba krb5-user winbind libpam-winbind libnss-winbind libpam-krb5 krb5-config wireguard resolvconf -y
>    ```
> 4. Si el error menciona `no space left on device`, comprueba el espacio disponible:
>    ```bash
>    df -h /
>    ```
>    Si queda menos de 2 GB libres, contacta con tu profesor.

---

### Error 2.2 — La pantalla azul de Kerberos no aparece o tiene el valor incorrecto

> [!bug] Cuándo se produce
> - **No aparece:** Kerberos ya estaba configurado de una instalación anterior en el servidor.
> - **Valor incorrecto:** Se escribió `boochan.space` en minúsculas, o cualquier otro valor distinto de `BOOCHAN.SPACE`.

> [!caution] ¿Hay que preocuparse?
> **Sí.** Si el reino Kerberos queda en minúsculas o con un valor erróneo, ningún usuario podrá autenticarse en el dominio de la Fase 4.

> [!example] Resolución
> Abre la pantalla de configuración de Kerberos en cualquier momento:
> ```bash
> sudo dpkg-reconfigure krb5-config
> ```
> Cuando aparezca la pantalla azul:
> 1. Borra lo que haya en el campo de texto.
> 2. Escribe exactamente: `BOOCHAN.SPACE` (todo en mayúsculas).
> 3. Pulsa `Tab` para mover el cursor al botón `<Ok>` y luego `Enter`.
> 4. Si aparecen pantallas adicionales, déjalas en blanco y pulsa `Enter`.

---

### Error 2.3 — Conflicto entre `resolvconf` y `systemd-resolved`

> [!bug] Cuándo se produce
> No se detecta en la Fase 2. El síntoma aparece en la **Fase 4**, cuando `cat /etc/resolv.conf` muestra una IP de Azure en lugar de `127.0.0.1`.

> [!warning] ¿Hay que preocuparse?
> Sí. Si el DNS no apunta al propio servidor, el dominio no funcionará y ningún cliente podrá unirse a él.

> [!example] Resolución
> Ver **Error 4.3** — el procedimiento completo está documentado allí, ya que es en la Fase 4 donde se detecta y resuelve.

---

### Error 2.4 — `hostname -f` devuelve el FQDN incorrecto tras reiniciar

> [!bug] Cuándo se produce
> Cuando se editó `/etc/hosts` para añadir el FQDN pero no se editó `/etc/hostname`. En Azure, el nombre del servidor puede restablecerse al valor original tras un reinicio.

> [!caution] ¿Hay que preocuparse?
> **Sí.** Si el FQDN no es estable, Kerberos generará tickets con el nombre incorrecto y la autenticación fallará en la Fase 4.

> [!example] Resolución
> 1. Comprueba el valor actual:
>    ```bash
>    cat /etc/hostname
>    ```
> 2. Si no contiene exactamente `UbuntuServer`, edítalo:
>    ```bash
>    sudo nano /etc/hostname
>    ```
>    Borra lo que haya y escribe únicamente: `UbuntuServer`. Guarda y sal.
> 3. Aplica el cambio sin reiniciar:
>    ```bash
>    sudo hostnamectl set-hostname UbuntuServer
>    ```
> 4. Verifica:
>    ```bash
>    hostname -f
>    ```
>    Debe devolver: `UbuntuServer.BOOCHAN.SPACE`

---

## Fase 3 — Conectividad VPN (WireGuard)

---

### Error 3.1 — La clave pública pegada en `wg0.conf` tiene caracteres invisibles

> [!bug] Cuándo se produce
> Al copiar la clave pública desde la aplicación WireGuard de Windows y pegarla en el terminal con clic derecho. Windows a veces añade un salto de línea o un espacio invisible al final que no se ve en pantalla pero rompe la conexión completamente.

> [!caution] ¿Hay que preocuparse?
> **Sí.** WireGuard no muestra ningún error claro; simplemente no habrá conexión y el `ping 10.0.0.1` no responderá nunca.

> [!example] Resolución
> 1. Verifica el contenido real de la clave en el fichero:
>    ```bash
>    sudo grep PublicKey /etc/wireguard/wg0.conf
>    ```
> 2. La salida debe ser una sola línea limpia, sin espacios ni caracteres `<` o `>`:
>    ```
>    PublicKey = aBcDeFgHiJkLmNoPqRsTuVwXyZ1234567890abcde=
>    ```
> 3. Si hay algo raro, edita el fichero y reescribe la línea desde cero:
>    ```bash
>    sudo nano /etc/wireguard/wg0.conf
>    ```
> 4. Tras corregirlo, reinicia el túnel:
>    ```bash
>    sudo wg-quick down wg0
>    sudo wg-quick up wg0
>    ```

---

### Error 3.2 — El túnel arranca sin errores pero no hay ping entre cliente y servidor

> [!bug] Cuándo se produce
> Cuando `sudo wg-quick up wg0` no da error pero el `ping 10.0.0.1` desde el PC del aula no obtiene respuesta.

> [!warning] ¿Hay que preocuparse?
> Sí. El túnel está mal configurado. Hay que diagnosticar la causa antes de continuar.

> [!example] Resolución — Comprueba en este orden
> **1. ¿Está el puerto 51820 UDP abierto en Azure?**
> Revisa el NSG. Debe haber una regla con puerto `51820`, protocolo **UDP** (no TCP) y acción Permitir.
>
> **2. ¿Están las claves cruzadas correctamente?**
> - La clave pública del **servidor** debe estar en el fichero de configuración del **cliente** (app WireGuard de Windows).
> - La clave pública del **cliente** debe estar en el bloque `[Peer]` del fichero `/etc/wireguard/wg0.conf` del **servidor**.
>
> Comprueba la clave pública real del servidor:
> ```bash
> sudo cat /etc/wireguard/publickey
> ```
>
> **3. ¿Está el túnel activo en el cliente?**
> En la app WireGuard de Windows, el botón debe mostrar "Desactivar". Si dice "Activar", el túnel no está conectado.
>
> **4. Verifica el estado del túnel en el servidor:**
> ```bash
> sudo wg show
> ```
> Si aparece el peer con `latest handshake` reciente, el túnel funciona y el problema es otro. Si no hay ningún `latest handshake`, las claves están mal intercambiadas.

---

### Error 3.3 — `Address already in use` al levantar el túnel

> [!bug] Cuándo se produce
> Al ejecutar `sudo wg-quick up wg0` cuando ya hay una interfaz `wg0` activa de un intento anterior.

> [!info] ¿Hay que preocuparse?
> No. Es un error sencillo y no ha causado ningún daño.

> [!example] Resolución
> Baja el túnel primero y luego vuelve a levantarlo:
> ```bash
> sudo wg-quick down wg0
> sudo wg-quick up wg0
> ```

---

## Fase 4 — Dominio Samba AD DC

---

### Error 4.1 — `git clone` falla porque la URL no fue sustituida

> [!bug] Cuándo se produce
> Al ejecutar el comando de descarga del repositorio sin sustituir el texto `URL_DEL_REPOSITORIO` por la URL real. Git devuelve un error inmediato.

> [!info] ¿Hay que preocuparse?
> No. El comando falla al instante sin haber hecho ningún cambio en el servidor.

> [!example] Resolución
> 1. Pide a tu profesor la URL real del repositorio.
> 2. Vuelve a ejecutar el comando sustituyendo el texto completo:
>    ```bash
>    git clone https://la-url-real-del-repositorio /opt/boochan
>    ```

---

### Error 4.2 — El script se detiene sin mostrar el mensaje de éxito

> [!bug] Cuándo se produce
> Cuando el script `provision_boochan.sh` falla antes de completarse. El terminal se detiene mostrando un error y nunca aparece la línea `Despliegue de BOOCHAN finalizado`.

> [!caution] ¿Hay que preocuparse?
> **Sí.** Si el script no terminó, el dominio no existe o está a medias y no funcionará en las fases siguientes.

> [!example] Resolución
> Lee el último mensaje de error visible. Los más frecuentes:
>
> **"Failed to set up Domain":** El FQDN no está bien configurado. Vuelve a la Fase 2 y verifica que `hostname -f` devuelve `UbuntuServer.BOOCHAN.SPACE`.
>
> **"Port 445 already in use":** Quedó algún proceso de Samba activo. Límpialo y vuelve a ejecutar el script:
> ```bash
> sudo systemctl stop smbd nmbd winbind 2>/dev/null || true
> sudo apt-get purge samba* -y
> sudo rm -rf /etc/samba/ /var/lib/samba/ /var/cache/samba/
> sudo ./provision_boochan.sh
> ```
>
> Si el error no está en esta lista, anótalo y muéstraselo a tu profesor antes de continuar.

---

### Error 4.3 — `resolv.conf` muestra una IP de Azure en lugar de `127.0.0.1`

> [!bug] Cuándo se produce
> Tras ejecutar el script, al verificar el DNS con `cat /etc/resolv.conf`. El fichero muestra una IP de Azure (como `168.63.129.16`) en lugar de `nameserver 127.0.0.1`.

> [!caution] ¿Hay que preocuparse?
> **Sí.** Es uno de los errores más críticos del proyecto. Sin el DNS correcto, el dominio no resolverá nombres y ningún cliente podrá unirse.

> [!example] Resolución — Desactivar `systemd-resolved` y fijar el DNS
> 1. Desactiva y detén el servicio que está interfiriendo:
>    ```bash
>    sudo systemctl disable systemd-resolved --now
>    ```
> 2. Elimina el enlace simbólico que gestiona ese servicio:
>    ```bash
>    sudo rm /etc/resolv.conf
>    ```
> 3. Crea un nuevo fichero con el DNS correcto:
>    ```bash
>    echo "nameserver 127.0.0.1" | sudo tee /etc/resolv.conf
>    ```
> 4. Bloquea el fichero para que nada pueda modificarlo:
>    ```bash
>    sudo chattr +i /etc/resolv.conf
>    ```
> 5. Verifica el resultado:
>    ```bash
>    cat /etc/resolv.conf
>    ```
>    Debe mostrar únicamente: `nameserver 127.0.0.1`
> 6. Reinicia Samba:
>    ```bash
>    sudo systemctl restart samba-ad-dc
>    ```

---

### Error 4.4 — `nslookup: command not found`

> [!bug] Cuándo se produce
> Al ejecutar la verificación del Punto de Control con `nslookup`. En Ubuntu Server mínimo esta herramienta no viene instalada y el terminal devuelve `command not found`.

> [!info] ¿Hay que preocuparse?
> No. No significa que el DNS esté roto; simplemente falta la herramienta para comprobarlo.

> [!example] Resolución
> Instala el paquete que incluye `nslookup`:
> ```bash
> sudo apt install dnsutils -y
> ```
> Tras la instalación, vuelve a ejecutar la verificación:
> ```bash
> nslookup _kerberos._tcp.BOOCHAN.SPACE
> ```

---

## Fase 5 — Gestión de Identidades

---

### Error 5.1 — `id user1` no devuelve nada o dice "no such user"

> [!bug] Cuándo se produce
> Al verificar el Punto de Control, cuando el resultado esperado (`uid=10001`, `gid=3001`) no aparece, aunque el usuario fue creado correctamente en el dominio.

> [!warning] ¿Hay que preocuparse?
> Depende de la causa. El usuario puede existir perfectamente en el dominio pero el sistema no lo "ve" porque el traductor no está activo.

> [!example] Resolución — Comprueba en este orden
> **1. ¿Está winbind corriendo?**
> ```bash
> sudo systemctl status winbind
> ```
> Si no dice `active (running)`, arráncalo:
> ```bash
> sudo systemctl enable winbind --now
> ```
> Vuelve a probar `id user1`.
>
> **2. ¿Está winbind en el fichero de búsqueda de usuarios?**
> ```bash
> grep "passwd" /etc/nsswitch.conf
> ```
> La línea debe incluir `winbind` al final. Si no está, edita el fichero:
> ```bash
> sudo nano /etc/nsswitch.conf
> ```
> Deja las líneas `passwd:` y `group:` así:
> ```
> passwd:         files systemd winbind
> group:          files systemd winbind
> ```
>
> **3. ¿El usuario existe en el dominio?**
> ```bash
> sudo samba-tool user list
> ```
> Si `user1` aparece, el problema era de winbind (pasos anteriores). Si no aparece, repite el Paso 3 de la Fase 5.

---

### Error 5.2 — Error de esquema LDAP al ejecutar `addunixattrs`

> [!bug] Cuándo se produce
> Al ejecutar `sudo samba-tool group addunixattrs policia 3001`, el terminal devuelve un error con palabras como "no such attribute", "schema" o "LDAP".

> [!caution] ¿Hay que preocuparse?
> **Sí.** El dominio fue provisionado sin soporte para atributos Unix (RFC 2307). Hay que reprovisionar.

> [!example] Resolución
> Este proceso borra todos los datos del dominio actual. Informa a tu profesor antes de ejecutarlo:
> 1. Detén Samba:
>    ```bash
>    sudo systemctl stop samba-ad-dc
>    ```
> 2. Elimina la base de datos del dominio:
>    ```bash
>    sudo rm -rf /var/lib/samba/private/
>    sudo rm -rf /var/lib/samba/sysvol/
>    ```
> 3. Vuelve a ejecutar el script de la Fase 4. Verifica con tu profesor que el script incluye el parámetro `--use-rfc2307`.

---

### Error 5.3 — "Group already exists" o "User already exists"

> [!bug] Cuándo se produce
> Al intentar crear un grupo o usuario que ya fue creado en un intento anterior de esta fase.

> [!info] ¿Hay que preocuparse?
> No. Solo hay que eliminar el objeto existente y volver a crearlo.

> [!example] Resolución
> Para grupos:
> ```bash
> sudo samba-tool group delete policia
> sudo samba-tool group delete bomberos
> ```
> Para usuarios:
> ```bash
> sudo samba-tool user delete user1
> sudo samba-tool user delete user2
> ```
> Después vuelve a ejecutar los pasos de creación desde el principio.

---

## Fase 6 — Almacenamiento Virtual

---

### Error 6.1 — El servidor no arranca tras editar el `fstab`

> [!bug] Cuándo se produce
> Cuando se guarda `/etc/fstab` con un error de sintaxis (por ejemplo, olvidando la palabra `loop`) y se reinicia el servidor sin haber ejecutado `sudo mount -a` para verificarlo primero.

> [!caution] ¿Hay que preocuparse?
> **Sí.** Es el error más grave de esta fase. El servidor entra en modo de emergencia y la conexión SSH no funciona.

> [!example] Resolución — Acceso por Consola de Serie de Azure
> 1. Entra en el portal de Azure ([portal.azure.com](https://portal.azure.com)).
> 2. Localiza tu VM `UbuntuServer` → menú izquierdo → **"Consola de serie"**.
> 3. Pulsa `Enter`. Inicia sesión con `boochan` y `P@ssw0rd.SOR.2026`.
> 4. Edita el fichero y corrige la línea errónea:
>    ```bash
>    sudo nano /etc/fstab
>    ```
>    Las líneas de los discos virtuales deben tener exactamente este formato:
>    ```
>    /samba_p1.img  /srv/samba/prueba1  ext4  loop,defaults  0  0
>    /samba_p3.img  /srv/samba/prueba3  ext4  loop,defaults  0  0
>    ```
> 5. Antes de reiniciar, verifica que la sintaxis es correcta:
>    ```bash
>    sudo mount -a
>    ```
>    Si el terminal no devuelve ningún texto, la sintaxis es perfecta.
> 6. Reinicia:
>    ```bash
>    sudo reboot
>    ```

---

### Error 6.2 — La conexión SSH se corta al ejecutar `sudo reboot`

> [!bug] Cuándo se produce
> Al ejecutar `sudo reboot` para verificar que los discos se montan solos. El terminal muestra `Connection reset by peer` o `Broken pipe` y deja de responder.

> [!info] ¿Hay que preocuparse?
> No. Es completamente normal. El servidor se está reiniciando.

> [!example] Resolución
> 1. Cierra el terminal. No hay nada que recuperar.
> 2. Espera **2-3 minutos**.
> 3. Vuelve a conectarte:
>    ```bash
>    ssh -p 2222 boochan@10.0.0.1
>    ```
> 4. Una vez dentro, ejecuta `df -h` para confirmar que los discos de 5 GB aparecen montados.

---

### Error 6.3 — `chown root:policia` falla con "invalid group"

> [!bug] Cuándo se produce
> Al ejecutar `sudo chown root:policia /srv/samba/prueba3` con el servicio `winbind` inactivo. Linux no reconoce el grupo `policia` porque es un grupo del dominio, no un grupo local.

> [!warning] ¿Hay que preocuparse?
> Sí. La carpeta quedará con grupo `root` y los permisos de la Fase 7 no funcionarán correctamente.

> [!example] Resolución
> 1. Arranca winbind:
>    ```bash
>    sudo systemctl enable winbind --now
>    ```
> 2. Verifica que el grupo es reconocible:
>    ```bash
>    getent group policia
>    ```
>    Debe devolver una línea con el GID del grupo. Si devuelve vacío, el dominio no está bien configurado — vuelve a la Fase 4.
> 3. Repite el comando:
>    ```bash
>    sudo chown root:policia /srv/samba/prueba3
>    ```
> 4. Verifica el resultado:
>    ```bash
>    ls -la /srv/samba/ | grep prueba3
>    ```
>    La columna de grupo debe mostrar `policia`.

---

### Error 6.4 — El comando `dd` falla con "No space left on device"

> [!bug] Cuándo se produce
> Al crear los archivos de disco virtual con `dd`, si el disco principal del servidor no tiene espacio suficiente para dos archivos de 5 GB.

> [!warning] ¿Hay que preocuparse?
> Sí. No se pueden crear los discos virtuales y la Fase 6 no puede completarse.

> [!example] Resolución
> 1. Comprueba el espacio disponible:
>    ```bash
>    df -h /
>    ```
> 2. Si hay archivos `.img` de un intento anterior ocupando espacio, elimínalos:
>    ```bash
>    sudo rm -f /samba_p1.img /samba_p3.img
>    ```
> 3. Si aún no hay espacio suficiente (se necesitan al menos 12 GB libres), consulta con tu profesor para ampliar el disco desde el portal de Azure, o reduce el tamaño de los discos cambiando `count=5120` por `count=2048` en los comandos `dd` (generará discos de 2 GB en lugar de 5 GB).

---

## Fase 7 — Seguridad Avanzada (ACLs y ABE)

---

### Error 7.1 — Samba no arranca tras editar `smb.conf`

> [!bug] Cuándo se produce
> Después de añadir los bloques de `[prueba1]` y `[prueba3]` al fichero `smb.conf`, al ejecutar `sudo systemctl restart samba-ad-dc` el servicio queda en estado `failed`.

> [!warning] ¿Hay que preocuparse?
> No es grave. Hay un error de sintaxis en el fichero que Samba identifica con precisión.

> [!example] Resolución
> 1. Pide a Samba que analice el fichero y señale el error:
>    ```bash
>    sudo testparm
>    ```
>    La salida indica el número de línea con el problema.
> 2. Edita el fichero y corrige esa línea:
>    ```bash
>    sudo nano /etc/samba/smb.conf
>    ```
>    Los errores más frecuentes son espacios inconsistentes, olvidar el `=` en algún parámetro, o escribir `Yes` con mayúscula cuando Samba espera `yes`.
> 3. Tras corregirlo, verifica y reinicia:
>    ```bash
>    sudo testparm
>    sudo systemctl restart samba-ad-dc
>    ```

---

### Error 7.2 — Secciones `[prueba1]` o `[prueba3]` duplicadas en `smb.conf`

> [!bug] Cuándo se produce
> Cuando el script de la Fase 4 ya había añadido esas secciones y se añadieron de nuevo siguiendo el Paso 2 de esta fase sin comprobarlo primero.

> [!warning] ¿Hay que preocuparse?
> Samba puede usar la configuración incorrecta o mostrar avisos confusos que dificultan el diagnóstico.

> [!example] Resolución
> 1. Localiza las secciones duplicadas:
>    ```bash
>    sudo grep -n "\[prueba" /etc/samba/smb.conf
>    ```
>    Si cada sección aparece más de una vez, hay duplicados.
> 2. Edita el fichero y elimina el bloque duplicado (conserva el que tenga todos los parámetros completos):
>    ```bash
>    sudo nano /etc/samba/smb.conf
>    ```
> 3. Verifica y reinicia:
>    ```bash
>    sudo testparm
>    sudo systemctl restart samba-ad-dc
>    ```

---

### Error 7.3 — `user1` ve la carpeta `prueba3` pero no puede crear archivos

> [!bug] Cuándo se produce
> Cuando las ACLs se aplicaron pero el grupo `policia` no es el propietario de la carpeta o los permisos Unix base no son correctos.

> [!warning] ¿Hay que preocuparse?
> Sí. El objetivo de esta fase es que `user1` (policia) pueda escribir en `prueba3`.

> [!example] Resolución
> 1. Verifica los permisos actuales:
>    ```bash
>    ls -la /srv/samba/ | grep prueba3
>    getfacl /srv/samba/prueba3
>    ```
> 2. Corrige el propietario y los permisos Unix:
>    ```bash
>    sudo chown root:policia /srv/samba/prueba3
>    sudo chmod 2770 /srv/samba/prueba3
>    ```
> 3. Vuelve a aplicar las ACLs:
>    ```bash
>    sudo setfacl -m g:policia:rwx /srv/samba/prueba3
>    sudo setfacl -d -m g:policia:rwx /srv/samba/prueba3
>    ```
> 4. Reinicia Samba:
>    ```bash
>    sudo systemctl restart samba-ad-dc
>    ```

---

## Fase 8 — Integración del Cliente Windows 11

---

### Error 8.1 — Windows pierde acceso a internet tras cambiar el DNS

> [!bug] Cuándo se produce
> Al cambiar el DNS preferido a `10.0.0.1` sin añadir un DNS alternativo. Si el servidor no reenvía consultas de internet al exterior, Windows queda sin acceso a la red.

> [!warning] ¿Hay que preocuparse?
> No es grave, pero impide instalar RSAT en el Paso 5 y usar el navegador.

> [!example] Resolución
> 1. Ve a la configuración de red de Windows: **Red** → **Ethernet / Wi-Fi** → **Editar** → **Manual** → **IPv4**.
> 2. Añade en el campo **"DNS alternativo"**: `8.8.8.8`
> 3. Pulsa **"Guardar"** y verifica que el navegador vuelve a funcionar.

---

### Error 8.2 — "No se puede contactar con el dominio" al unirse o iniciar sesión

> [!bug] Cuándo se produce
> En dos momentos: al intentar unir el PC al dominio en el Paso 3, o al iniciar sesión con `BOOCHAN\user1` en el Paso 4 tras el reinicio.

> [!caution] ¿Hay que preocuparse?
> **Sí.** Sin acceso al controlador de dominio no se puede autenticar ningún usuario.

> [!example] Resolución — Comprueba en este orden
> **1. ¿Está la VPN activa?**
> Abre la aplicación WireGuard. El botón debe mostrar "Desactivar". Si dice "Activar", pulsa el botón y espera unos segundos.
>
> **2. ¿Responde el servidor?**
> Abre el Símbolo del sistema (`cmd`) y ejecuta:
> ```cmd
> ping 10.0.0.1
> ```
> Si no hay respuesta, el túnel no funciona. Consulta los Errores 3.1 y 3.2.
>
> **3. ¿Encuentra el dominio el DNS?**
> ```cmd
> nslookup BOOCHAN.SPACE
> ```
> Debe devolver la IP `10.0.0.1`. Si no, comprueba que el DNS preferido es `10.0.0.1` (Paso 1 de la Fase 8).

---

### Error 8.3 — Error de "Clock Skew" o "relación de confianza" al autenticarse

> [!bug] Cuándo se produce
> Al intentar iniciar sesión o unirse al dominio, cuando el reloj del PC y el del servidor difieren más de 5 minutos. Kerberos rechaza cualquier autenticación con ese desfase.

> [!warning] ¿Hay que preocuparse?
> Sí. Ningún usuario podrá autenticarse hasta que los relojes estén sincronizados.

> [!example] Resolución
> 1. Abre el **Símbolo del sistema como Administrador** (`Windows + X` → "Terminal de Windows (Administrador)").
> 2. Fuerza la sincronización del reloj:
>    ```cmd
>    w32tm /resync /force
>    ```
> 3. Si el error persiste, comprueba la zona horaria del servidor Linux:
>    ```bash
>    timedatectl
>    ```
>    Tanto el servidor como el cliente deben tener la hora UTC correcta, aunque estén en zonas horarias diferentes.

---

### Error 8.4 — La unidad de red `Z:` desaparece al reiniciar Windows

> [!bug] Cuándo se produce
> Después de mapear la unidad correctamente, tras reiniciar el PC la unidad `Z:` desaparece del explorador de archivos porque el mapeo no se marcó como persistente.

> [!info] ¿Hay que preocuparse?
> No. Es un comportamiento normal del comando `net use` sin el parámetro de persistencia.

> [!example] Resolución
> Vuelve a mapear la unidad añadiendo `/persistent:yes`. Abre el Símbolo del sistema:
> ```cmd
> net use Z: \\UbuntuServer.BOOCHAN.SPACE\prueba1 /user:BOOCHAN\user1 /persistent:yes
> ```
> A partir de ahora la unidad se reconectará automáticamente al iniciar sesión, siempre que la VPN esté activa.

---

### Error 8.5 — El login de dominio no funciona por error en el nombre de usuario

> [!bug] Cuándo se produce
> Al escribir el usuario del dominio en la pantalla de inicio de sesión de Windows con el formato incorrecto.

> [!info] ¿Hay que preocuparse?
> No es grave. Es un error de formato, no un problema del sistema.

> [!example] Resolución
> Comprueba estos puntos:
>
> **La barra debe ser invertida `\`, no la barra normal `/`.**
> La barra invertida se escribe con la tecla `\` del teclado (normalmente junto al `Intro` o junto al `0` en teclados españoles).
>
> **El nombre del dominio es `BOOCHAN`, sin el `.SPACE`.**
> El formato correcto es: `BOOCHAN\user1`
>
> **¿Está la VPN activa?**
> Sin VPN, aunque el formato sea correcto, la autenticación fallará. Ver Error 8.2.

---

*Proyecto BoochanV2 — Curso 2025/2026*
