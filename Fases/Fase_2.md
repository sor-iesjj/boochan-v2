## 🧹 Fase 2: Purga y Preparación del Entorno

### Infraestructura de Servidores Cloud

> **[Módulo: SOR — Sistemas Operativos en Red]**
> **[U.T. 5: Administración en Linux - Instalación y Configuración]**
> **[RA.02]** Gestiona usuarios y grupos, interpretando especificaciones y aplicando herramientas del sistema.
>
> **Profesor:** Pedro Navarro Miralles  
> **Correo:** p.navarromiralles2@edu.gva.es  
> **Centro:** IES Jorge Juan (ALICANTE)
>
> **⏱️ Tiempo estimado:** ~1,25 horas (teoría + práctica + retos + troubleshooting)  
> **Requisitos:** 2 GB RAM | Conectividad internet | SSH

---

> [!important] 📹 Obligaciones de grabación (LÉEME — es igual en TODAS las fases)
> Esta práctica se **graba entera con OBS**, de principio a fin. No es un repaso al final: quiero ver **cómo lo haces tú**.
> 1. **Prepárate primero (sin grabar):** comprueba lo necesario, **léete el procedimiento entero** y **crea la entrada de apuntes de esta fase** en Obsidian: fichero `v2-fase-2-purga-y-preparacion-del-entorno.md` dentro de `00_Apuntes/Trimestre_N/B4_Ubuntu_Nube/`, con la estructura de la Fase 0.1 y **vacía**. Rellenarla es cosa tuya, después.
> 2. **Arranca OBS y PRESÉNTATE:** *"Hola, me llamo [Nombre], 2.º SMR, y en este vídeo voy a explicar la Fase 2 de Boochan V2 — Purga y Preparación del Entorno."* Y **muestra algo que demuestre que eres tú** (tu perfil de GitHub, tu Teams o tu correo `@alu.edu.gva.es`). Di qué vas a hacer.
> 3. **Graba TODO el procedimiento**, explicando cada paso en voz alta mientras lo haces.
> 4. **Timestamps SIEMPRE** en la descripción: `00:00 Presentación` + uno por cada paso.
> 5. **Al terminar:** nombra el vídeo `V2 · Fase 2 — Purga y Preparación del Entorno`, súbelo a tu playlist de YouTube **`B4_Ubuntu_Nube`** (No listado) y **copia su enlace**.
> 6. **~8-10 min.** Esta fase es más larga que las de prerrequisitos: ve al grano, pero no te saltes pasos. Si se te va mucho, **pártela en dos vídeos** y ponlos los dos en la entrada.
> 7. **El enlace del vídeo va DENTRO de tu entrada de apuntes**, en el apartado `Enlace al vídeo explicativo`. Ahí, no en un papel.
> 8. **La entrega va por la TAREA de Teams.** Abriré una tarea que cubrirá **esta fase y otras**; te llegará notificación con fecha límite.

---

### 🎯 ¿Dónde Estamos?

> [!info] Vienes de Fase 1
> Creaste un servidor Ubuntu en Azure. Está encendido, accesible por SSH, protegido por NSG. Pero viene "de fábrica" con software innecesario: servicios antiguos, demonios durmiendo, paquetes que consumirán RAM y podrían ser puertas de seguridad.

> [!warning] El Problema
> Ubuntu instala de serie Samba básico (para "compartir archivos entre amigos"). Este Samba primitivo ocupa el puerto 445, que tu futuro **Controlador de Dominio profesional** (Fase 4) necesitará. Además, servicios como CUPS (impresoras) o IMAP (correo) están dormidos pero activos, consumiendo recursos. El servidor tampoco sabe su identidad: `/etc/hosts` dice "localhost" sin un verdadero nombre de dominio.

> [!success] Objetivo de esta Fase
> **Purga:** Eliminar completamente Samba viejo, impresoras, CUPS, servicios heredados. **Identidad:** Configurar `/etc/hosts` para que el servidor sepa que se llama `UbuntuServer.BOOCHAN.SPACE`. Esto es imprescindible porque Kerberos (Fase 4) valida identidades por nombre de dominio completo (FQDN).

> [!tip] Hoja de Ruta
> 1. Ejecutar `apt update && apt upgrade -y` (actualizar repositorio y parches de seguridad)
> 2. Usar `apt purge` (no solo `remove`) para borrar Samba viejo, CUPS, servicios heredados
> 3. Ejecutar `apt autoremove` para limpiar dependencias orfandas
> 4. Editar `/etc/hosts` e insertar: `10.0.0.1  UbuntuServer.BOOCHAN.SPACE  UbuntuServer`
> 5. Verificar con `hostname -f` que devuelve exactamente `UbuntuServer.BOOCHAN.SPACE`
> 6. Validar resolución: `ping UbuntuServer` y `ping UbuntuServer.BOOCHAN.SPACE` responden
>
> **Resultado Final:** Servidor limpio, sin ruido de servicios heredados, con identidad de dominio establecida.
> **Siguiente:** Fase 3 (Conectividad VPN) — instalarás WireGuard para que el aula pueda acceder de forma segura y privada al servidor.

---

### 📚 Fundamento Teórico Avanzado

> [!abstract] 1. Idempotencia: "La Pizarra Limpia"
> En la U.T. 5 aprendemos que un servidor profesional debe ser **idempotente** (puedes repetir el proceso y el resultado siempre será el mismo) y **predecible**. No podemos construir un rascacielos sobre los cimientos de una cabaña vieja.

> [!warning] 2. El Conflicto de Puertos (SMB 445)
> Muchas distribuciones Linux incluyen de serie servicios de archivos (Samba) para uso doméstico. Esto genera un conflicto:
> *   **El "Teléfono" de Red:** El puerto 445 (SMB) es el canal por el que Windows pide archivos.
> *   **El Conflicto:** Si un Samba básico ya está "escuchando" ese teléfono, nuestro potente Controlador de Dominio no podrá recibir llamadas y el sistema colapsará. La purga elimina el software viejo y sus configuraciones para liberar el puerto.

> [!tip] 3. Kerberos (krb5): El Taquillero del Cine
> Es el protocolo de autenticación que usa Windows. Imagínalo como un cine:
> *   **El KDC (Taquilla):** No vas directo a la sala. Primero vas a la taquilla, demuestras quién eres y compras un **Ticket (TGT)**.
> *   **El Ticket:** Se lo enseñas al acomodador (servidor de archivos). Él no necesita saber tu contraseña; solo necesita ver que tu ticket es oficial. Esto permite el **Single Sign-On (SSO)**: entrar una vez y acceder a todo.

> [!info] 4. Winbind: El Traductor de la ONU
> Linux y Windows hablan idiomas diferentes para identificar usuarios:
> *   **Windows:** Usa códigos largos (SIDs).
> *   **Linux:** Usa números cortos (UIDs).
> *   **La función:** Winbind actúa como traductor. Cuando llega un usuario de Windows, le dice a Linux: *"Este código raro equivale a nuestro número 10001"*. Sin este puente, Linux ignoraría a los usuarios de Windows.

> [!note] 5. ACLs y Atributos: Cirugía de Permisos
> En Linux básico usamos `rwx`, pero en una empresa eso se queda corto.
> *   **ACL (Access Control Lists):** Permiten permisos específicos: *"Juan lee, María escribe y Pedro borra"*, aunque no estén en el mismo grupo.
> *   **Atributos (attr):** Permiten guardar info extra que Samba necesita para "engañar" a Windows y que crea que el disco es NTFS (el formato de Windows).

> [!important] 6. El FQDN: Nombre y "Apellido" Digital
> Configurar el `/etc/hosts` es vital. Un servidor necesita un **FQDN (Fully Qualified Domain Name)** completo.
> *   **Nombre:** `UbuntuServer` | **Apellido:** `BOOCHAN.SPACE` | **FQDN:** `UbuntuServer.BOOCHAN.SPACE`
> Si Kerberos intenta dar un ticket para el nombre sin el "apellido", el sistema lo rechazará por falta de confianza.

### 📖 Diccionario de Conceptos Clave

> [!quote] Terminología Profesional
> - **Demonio (Daemon):** Un programa que vive y trabaja en segundo plano sin que tú lo veas (ej. `smbd`).
> - **FQDN:** El nombre completo y único de tu servidor en la red.
> - **Apt Purge:** Comando "agresivo" que borra el software Y todos sus archivos de configuración.
> - **Winbind:** El servicio que hace de puente entre identidades Linux y Windows.

---

### 🛠️ Procedimiento Práctico (BoochanV2)

> [!important] 🔌 Antes de empezar: Conéctate al servidor
> Todos los comandos de esta fase se ejecutan **dentro de tu servidor en Azure**, no en tu PC del aula. Abre una terminal y conéctate via SSH como hiciste en la Fase 1:
> ```bash
> ssh boochan@TU_IP_PUBLICA
> ```
> Cuando veas el símbolo `$` al final de la línea, ya estás listo para continuar.

> [!example] Paso 1: Limpieza Total del Entorno
> Antes de construir, debemos demoler lo viejo. Ejecuta estos comandos para liberar los puertos y limpiar la caché:
>
> > [!info] 📚 Diccionario de Comandos: Para entender la sintaxis exacta y ver ejemplos de `apt`, `systemctl` y `rm`, consulta el [[Diccionario_Comandos_Sistema]].
>
> ```bash
> # Detiene los servicios actuales (si no existen, el aviso es normal e inofensivo)
> sudo systemctl stop smbd nmbd winbind 2>/dev/null || true
> # Elimina agresivamente Samba y sus restos
> sudo apt-get purge samba* -y
> sudo apt-get autoremove -y
> # Borra carpetas manuales para evitar residuos configurados
> sudo rm -rf /etc/samba/ /var/lib/samba/ /var/cache/samba/ /run/samba/
> ```
>
> > [!tip] 💡 ¿Qué hace este comando?
> > - **El asterisco (`samba*`):** Es un "comodín". Le dice a Linux: "Borra todo lo que empiece por la palabra samba". Así nos aseguramos de no dejar herramientas sueltas.
> > - **El comando `rm -rf`:** Es la "demolición total". Borra carpetas aunque no estén vacías. Lo usamos porque a veces el desinstalador se olvida de borrar las bases de datos antiguas que podrían dar errores después.
> > - **El `2>/dev/null || true` en el `systemctl stop`:** Si Samba no estaba instalado todavía en esta instalación limpia de Ubuntu, el comando daría un error inofensivo. Esta parte le dice a Linux "si falla, ignóralo y continúa". Es completamente normal ver ese paso sin ningún mensaje.

> [!example] Paso 2: Instalación de Dependencias Críticas
> Instalamos las herramientas que permiten a Linux "disfrazarse" de servidor Windows:
> ```bash
> sudo apt update && sudo apt install acl attr samba krb5-user winbind libpam-winbind libnss-winbind libpam-krb5 krb5-config wireguard resolvconf -y
> ```
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

### 🚩 Resolución de Problemas y Evaluación

> [!bug] Troubleshooting (¿Algo no va bien?)
> | Problema | Causa Probable | Solución Sugerida |
> | :--- | :--- | :--- |
> | `apt purge` no encuentra Samba. | Samba no estaba instalado o ya lo borraste. | No te preocupes, verifica con `dpkg -l \| grep samba`. Si está vacío, perfecto. |
> | El nombre del servidor es incorrecto. | Error de escritura en `/etc/hostname` o `/etc/hosts`. | Ejecuta `hostname -f`. Debe devolver `UbuntuServer.BOOCHAN.SPACE`. |
> | La pantalla azul de Kerberos no aparece. | Ya está configurado de una instalación anterior. | Ejecuta `sudo dpkg-reconfigure krb5-config` para reconfigurarlo. |

> [!help] Preguntas Críticas (Autoevaluación)
> 1. ¿Qué diferencia real hay entre un `apt remove` y un `apt purge`?
> 2. ¿Para qué sirve el archivo `/etc/hosts` en la resolución de nombres local (sin salir a Internet)?
> 3. ¿Por qué es crítico que el FQDN sea idéntico en todos los archivos de configuración futuros?
> 4. 🔬 **Reto práctico:** Ejecuta `hostname -f` en el servidor. Compara la salida letra por letra con la línea que añadiste en `/etc/hosts`. ¿Coinciden exactamente, sin espacios ni diferencias de mayúsculas? Una sola diferencia hará que el dominio falle silenciosamente en la Fase 4 sin dar un error claro.
> 5. 🔬 **Reto práctico:** Ejecuta `ping UbuntuServer` y luego `ping UbuntuServer.BOOCHAN.SPACE` desde el propio servidor. ¿Responden los dos? ¿A qué IP resuelven? Si uno falla y el otro no, ¿qué línea del `/etc/hosts` tienes mal configurada?

---

> [!caution] 🛑 Auditoría y Evaluación (RA.02)
> El alumno debe demostrar que el servidor resuelve su propio FQDN. **Riesgo Crítico:** Si el `hosts` no coincide con el dominio que instalaremos en la Fase 4, Kerberos jamás sacará tickets y el proyecto fallará.

> [!success] 🏁 Punto de Control (Antes de seguir)
> - [ ] ¿El comando `hostname -f` devuelve `UbuntuServer.BOOCHAN.SPACE`?
> - [ ] ¿Has verificado que no hay servicios de Samba antiguos corriendo (`systemctl status smbd`)?

---

### ✅ Entregables y cierre

> [!abstract] Qué tienes que tener hecho al acabar esta fase
> | Entregable | Dónde vive | Qué debe contener |
> | :--- | :--- | :--- |
> | **Entrada de apuntes** | `00_Apuntes/Trimestre_N/B4_Ubuntu_Nube/v2-fase-2-purga-y-preparacion-del-entorno.md` | Estructura completa + **respuestas a las Preguntas Críticas y al 🔬 Reto** + **enlace del vídeo** |
> | **Vídeo** | Playlist `B4_Ubuntu_Nube` (No listado) | Nombrado `V2 · Fase 2 — Purga y Preparación del Entorno`, con presentación, identidad y timestamps |
> | **Repositorio** | Tu repo de apuntes en GitHub | La entrada, subida con `git add` → `commit` → `push` |
>
> > [!danger] ⚠️ Las respuestas van en la ENTRADA, no en un documento aparte
> > Las **Preguntas Críticas** y el **🔬 Reto** de más arriba no son decorativos: son la parte de la fase que demuestra que has entendido lo que has hecho, y no solo que has sabido copiar comandos. Se contestan **con tus palabras**, en el apartado `Respuesta a las preguntas` de tu entrada.
> > Una fase con el procedimiento perfecto y las preguntas en blanco está **incompleta**.
>
> > [!info] 🏷️ Por qué el nombre lleva `V2` delante
> > Porque el proyecto Boochan existe en **varias versiones** (VirtualBox, Hyper-V, Azure, AWS…) y algunas comparten bloque y playlist. Sin la etiqueta, la Fase 4 de Azure y la de AWS se llamarían **exactamente igual** y no habría forma de distinguirlas. Con ella, tu carpeta y tu playlist dicen siempre **qué versión hiciste**.
>
> > [!success] 🎯 Criterio de éxito
> > Abro tu repositorio, encuentro la entrada de esta fase, y dentro está: qué has hecho, qué has entendido, qué dudas te han quedado y el enlace al vídeo donde se te ve haciéndolo. Si falta el enlace o faltan las respuestas, la fase **no cuenta como entregada**.
>
> > [!tip] 💡 ¿Y si la fase te ha llevado tres clases?
> > **Una fase, una entrada.** No creas un fichero por día: abres el mismo y sigues escribiendo. Haz `commit` y `push` **al terminar cada sesión**, para no perder nunca más de un día de trabajo.
