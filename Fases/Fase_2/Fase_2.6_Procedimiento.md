## Fase 2 · Apartado 6 — 🛠️ Procedimiento práctico

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Purga y Preparación del Entorno**
> 🧭 Índice de la fase: [[Fase_2]]
>
> **📍 Cuándo se lee:** **Con la VM delante.** Aquí está el trabajo.

---

> [!important] 🔌 Antes de empezar: Conéctate al servidor
> Todos los comandos de esta fase se ejecutan **dentro de tu servidor en Azure**, no en tu PC del aula. Abre una terminal y conéctate via SSH como hiciste en la Fase 1:
> ```bash
> ssh boochan@TU_IP_PUBLICA
> ```
> Cuando veas el símbolo `$` al final de la línea, ya estás listo para continuar.

> [!example] 🎬 Antes de empezar (todavía SIN grabar, y luego arranca)
> Ya conoces el método desde los prerrequisitos, así que va solo el recordatorio:
> 1. **Crea la entrada de apuntes** de esta fase (`v2-fase-2-purga-y-preparacion-del-entorno.md`) con su estructura, vacía.
> 2. **Léete los 3 pasos** del procedimiento enteros, para no atascarte a mitad del vídeo.
> 3. Ten **OBS** listo y comprueba **pantalla y micrófono**.
>
> Cuando lo tengas: **arranca la grabación, preséntate y muestra tu identidad**. A partir de ahí, **todo queda grabado** — incluido cualquier paso previo de preparación que venga a continuación.

> [!example] Paso 1: Limpieza Total del Entorno
> Antes de construir, debemos demoler lo viejo. Ejecuta estos comandos para liberar los puertos y limpiar la caché:
>
> > [!info] 📚 Diccionario de Comandos: Para entender la sintaxis exacta y ver ejemplos de `apt`, `systemctl` y `rm`, consulta el [[Diccionario_Comandos_Sistema]].
>
> ```bash
> # 1. Detiene los servicios actuales (si no existen, el aviso es normal e inofensivo)
> sudo systemctl stop smbd nmbd winbind 2>/dev/null || true
>
> # 2. Elimina Samba, winbind y su configuración. Lista EXPLÍCITA, sin comodines
> sudo apt purge -y samba samba-common samba-common-bin winbind libnss-winbind libpam-winbind
> sudo apt autoremove -y
> ```
>
> > [!danger] ⚠️ Por qué la lista va escrita entera y no `apt purge samba*`
> > Verás por internet ese atajo con asterisco. **No lo uses en un borrado**, por dos motivos:
> > 1. **El asterisco sin comillas lo interpreta primero la shell**, no `apt`: bash intenta expandirlo contra los ficheros del directorio donde estés, y el comando puede acabar haciendo algo distinto de lo que crees.
> > 2. **Un comodín borra lo que caza, no lo que querías.** Y además **deja `winbind` vivo**, porque no empieza por "samba". En un servidor se escribe la lista de lo que se va a borrar, y se lee antes de pulsar Enter.
>
> > [!tip] 💡 ¿Qué hace este comando?
> > - **El asterisco (`samba*`):** Es un "comodín". Le dice a Linux: "Borra todo lo que empiece por la palabra samba". Así nos aseguramos de no dejar herramientas sueltas.
> > - **El comando `rm -rf`:** Es la "demolición total". Borra carpetas aunque no estén vacías. Lo usamos porque a veces el desinstalador se olvida de borrar las bases de datos antiguas que podrían dar errores después.
> > - **El `2>/dev/null || true` en el `systemctl stop`:** Si Samba no estaba instalado todavía en esta instalación limpia de Ubuntu, el comando daría un error inofensivo. Esta parte le dice a Linux "si falla, ignóralo y continúa". Es completamente normal ver ese paso sin ningún mensaje.

> [!example] Paso 2: Instalación de Dependencias Críticas
> Instalamos las herramientas que permiten a Linux "disfrazarse" de servidor Windows:
> ```bash
> sudo apt update && sudo apt install -y acl attr samba samba-ad-dc samba-ad-provision krb5-user winbind libpam-winbind libnss-winbind libpam-krb5 krb5-config wireguard resolvconf
> ```
>
> > [!danger] ⚠️ `samba-ad-dc` y `samba-ad-provision`: sin ellos la Fase 4 es IMPOSIBLE
> > **Desde Ubuntu 24.04, el paquete `samba` ya NO incluye lo necesario para montar un controlador de dominio.** Se reparte en dos paquetes aparte:
> >
> > | Paquete | Qué aporta | Qué pasa si falta |
> > | :--- | :--- | :--- |
> > | **`samba-ad-provision`** | Los ficheros de esquema de Active Directory | El aprovisionamiento falla: *"AD_DS_Attributes... not found"* |
> > | **`samba-ad-dc`** | El servicio `samba-ad-dc.service` y módulos internos | *"Unit samba-ad-dc.service does not exist"* y *"Module [samba_secrets] not found"* |
> >
> > Y lo peor: **los errores no aparecen aquí, sino dos fases más adelante**, en mitad del aprovisionamiento, con mensajes que no mencionan que falte un paquete.
> >
> > Comprueba que están:
> > ```bash
> > dpkg -s samba-ad-dc samba-ad-provision | grep -E '^Package|^Status'
> > ```

>
> > [!caution] ⚠️ Si el comando falla a mitad de la instalación
> > Este comando instala muchos paquetes a la vez. Si ves un error en rojo y la instalación se detiene, no entres en pánico. Ejecuta este comando para reparar los paquetes que quedaron a medias y vuelve a intentarlo:
> > ```bash
> > sudo apt --fix-broken install -y
> > sudo apt install acl attr samba krb5-user winbind libpam-winbind libnss-winbind libpam-krb5 krb5-config wireguard resolvconf -y
> > ```
>
> > [!important] 💡 La pantalla azul de Kerberos (`krb5-config`)
> > En algún momento durante la instalación, **la pantalla se pondrá completamente azul** y aparecerá un formulario preguntando por el "Reino Kerberos por defecto". No te asustes, es normal. Sigue estos pasos exactos:
> > 1. El cursor estará en un campo de texto. Escribe `BOOCHAN.SPACE` (**siempre en MAYÚSCULAS**).
> > 2. Pulsa la tecla `Tab` para seleccionar el botón `<Ok>` y luego pulsa `Enter`.
> > 3. Si aparecen más pantallas preguntando por servidores adicionales, déjalas en blanco y pulsa `Enter` para aceptar los valores por defecto.
> >
> > **¡Las mayúsculas son obligatorias!** Si escribes `boochan.space` en minúsculas, el sistema de seguridad Kerberos fallará más adelante y ningún usuario podrá autenticarse.
>
> > [!warning] ⚠️ Nota sobre `resolvconf` y el DNS del sistema
> > El paquete `resolvconf` que acabas de instalar puede entrar en conflicto con el servicio de DNS que Ubuntu trae por defecto (`systemd-resolved`). De momento no haremos nada; el script de la Fase 4 se encarga de resolver este conflicto automáticamente. Si en la Fase 4 el DNS no apunta a `127.0.0.1`, encontrarás el procedimiento de reparación en su tabla de troubleshooting.

> [!example] Paso 3: Configuración de la Identidad (FQDN)
> Debemos decirle al servidor quién es. Primero averiguamos su dirección IP en la red interna de Azure:
> ```bash
> # Muestra las IPs del servidor
> hostname -I
> ```
> > [!tip] 💡 ¿Qué IP anoto si aparecen varias?
> > El comando puede mostrar dos o tres números. Usa **la que empieza por `10.`** — es la IP privada de Azure. Ignora cualquier otra.
>
> Ahora fijamos el nombre del servidor de forma permanente. Primero editamos el archivo que guarda el nombre corto:
> ```bash
> sudo nano /etc/hostname
> ```
> Borra lo que haya y escribe únicamente esto:
> ```
> UbuntuServer
> ```
> Guarda y sal (`Ctrl + O`, `Enter`, `Ctrl + X`).
>
> A continuación abrimos el archivo de identidades de red:
> ```bash
> sudo nano /etc/hosts
> ```
> Dentro del archivo verás varias líneas existentes. **Añade la siguiente línea al final del archivo**, sustituyendo `10.X.X.X` por la IP que anotaste:
> ```
> 10.X.X.X  UbuntuServer.BOOCHAN.SPACE  UbuntuServer
> ```
> Guarda y sal (`Ctrl + O`, `Enter`, `Ctrl + X`).
>
> Verifica que el servidor se reconoce a sí mismo con el nombre completo:
> ```bash
> # Debe devolver: UbuntuServer.BOOCHAN.SPACE
> hostname -f
> ```
>
> > [!info] 📚 Recurso: Si no recuerdas cómo usar este editor, repasa la [[Guía_Editor_Nano]].

---

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_2.5_Fundamento_Teorico]] | [[Fase_2]] | [[Fase_2.7_Resolucion_Problemas]] |
