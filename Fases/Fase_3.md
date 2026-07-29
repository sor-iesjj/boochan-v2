## 🔒 Fase 3: Conectividad VPN (WireGuard)

### Infraestructura de Servidores Cloud

> **[Módulo: SOR — Sistemas Operativos en Red]**
> **[U.T. 9: Gestión remota e Integración en Red]**
> **[RA.05]** Realiza tareas de monitorización y uso del sistema operativo en red.
>
> **Profesor:** Pedro Navarro Miralles  
> **Correo:** p.navarromiralles2@edu.gva.es  
> **Centro:** IES Jorge Juan (ALICANTE)
>
> **⏱️ Tiempo estimado:** ~2 horas (teoría + práctica + retos + troubleshooting)  
> **Requisitos:** 2 GB RAM | WireGuard PC | Azure Portal | SSH

---

> [!important] 📹 Obligaciones de grabación (LÉEME — es igual en TODAS las fases)
> Esta práctica se **graba entera con OBS**, de principio a fin. No es un repaso al final: quiero ver **cómo lo haces tú**.
> 1. **Prepárate primero (sin grabar):** comprueba lo necesario, **léete el procedimiento entero** y **crea la entrada de apuntes de esta fase** en Obsidian: fichero `v2-fase-3-conectividad-vpn-wireguard.md` dentro de `00_Apuntes/Trimestre_N/B4_Ubuntu_Nube/`, con la estructura de la Fase 0.1 y **vacía**. Rellenarla es cosa tuya, después.
> 2. **Arranca OBS y PRESÉNTATE:** *"Hola, me llamo [Nombre], 2.º SMR, y en este vídeo voy a explicar la Fase 3 de Boochan V2 — Conectividad VPN (WireGuard)."* Y **muestra algo que demuestre que eres tú** (tu perfil de GitHub, tu Teams o tu correo `@alu.edu.gva.es`). Di qué vas a hacer.
> 3. **Graba TODO el procedimiento**, explicando cada paso en voz alta mientras lo haces.
> 4. **Timestamps SIEMPRE** en la descripción: `00:00 Presentación` + uno por cada paso.
> 5. **Al terminar:** nombra el vídeo `V2 · Fase 3 — Conectividad VPN (WireGuard)`, súbelo a tu playlist de YouTube **`B4_Ubuntu_Nube`** (No listado) y **copia su enlace**.
> 6. **~8-10 min.** Esta fase es más larga que las de prerrequisitos: ve al grano, pero no te saltes pasos. Si se te va mucho, **pártela en dos vídeos** y ponlos los dos en la entrada.
> 7. **El enlace del vídeo va DENTRO de tu entrada de apuntes**, en el apartado `Enlace al vídeo explicativo`. Ahí, no en un papel.
> 8. **La entrega va por la TAREA de Teams.** Abriré una tarea que cubrirá **esta fase y otras**; te llegará notificación con fecha límite.

---

### 🎯 ¿Dónde Estamos?

> [!info] Vienes de Fase 2
> Completaste la purga del servidor y le diste identidad de dominio (UbuntuServer.BOOCHAN.SPACE). Ahora tienes un servidor limpio, profesional, con identidad. Pero hay un problema crítico: está expuesto a internet público. El puerto SSH (22) está abierto a todo el mundo — bots intentarán conectarse miles de veces por día.

> [!warning] El Problema
> Sin una VPN privada, tu servidor es vulnerable a ataques de fuerza bruta. Cualquiera en internet puede intentar adivinar contraseñas. Además, en las próximas fases necesitarás que el aula acceda al servidor desde cualquier lugar, pero solo el aula — no todo el mundo. Necesitas un túnel privado cifrado que solo tú controles.

> [!success] Objetivo de esta Fase
> Instalar **WireGuard**: una VPN ligera y moderna que crea un túnel P2P cifrado entre tu PC del aula (10.0.0.2) y el servidor (10.0.0.1). Este túnel es tu "puerta trasera" secreta — solo quien tenga las llaves criptográficas puede entrar. Cerrarás el puerto SSH directo a internet y aceptarás conexiones solo desde dentro de la VPN.

> [!tip] Hoja de Ruta
> 1. Abrir puerto 51820 UDP en Azure NSG (WireGuard escucha aquí)
> 2. Instalar WireGuard en el servidor
> 3. Generar pares de llaves criptográficas (servidor + tu PC)
> 4. Crear archivo de configuración `wg0.conf` en el servidor
> 5. Crear perfil VPN para tu PC del aula
> 6. Activar el túnel y verificar con `ping 10.0.0.1` desde tu PC
> 7. Cerrar puerto SSH público (22) y abrir solo el puerto 2222 para SSH vía VPN
>
> **Resultado Final:** Servidor accesible solo a través del túnel VPN. Totalmente blindado contra ataques de internet público.
> **Siguiente:** Fase 4 (Dominio) — provisionar el Active Directory. Ahora que hay conexión VPN segura, puedes instalar servicios críticos.

---

### 📚 Fundamento Teórico

> [!abstract] 1. El Dilema de la Nube
> La conectividad en la nube presenta un gran reto: queremos administrar nuestro servidor desde cualquier parte, pero no queremos exponerlo a ataques de todo el mundo. La solución es crear un **Túnel VPN P2P (Peer-to-Peer)**.

> [!info] 2. ¿Qué es WireGuard?
> A diferencia de protocolos antiguos (como Proxy o OpenVPN), WireGuard funciona al nivel del **Kernel** de Linux. Esto lo hace invisible para los atacantes y extremadamente rápido. Utiliza **criptografía de curva elíptica**, asegurando que los datos viajen por un canal 100% blindado.

> [!important] 3. Intercambio de Llaves
> El servidor y el cliente se reconocen mediante un intercambio de llaves: 
> *   **Llave Pública:** Se puede compartir (es como la dirección de tu casa).
> *   **Llave Privada:** Es el secreto absoluto. Solo quien posee la llave privada puede descifrar el tráfico que le llega.

### 📖 Diccionario de Conceptos Clave

> [!quote] Terminología VPN
> - **Cifrado Asimétrico:** Sistema que usa una llave para cerrar (pública) y otra distinta para abrir (privada).
> - **wg0.conf:** El "cerebro" o archivo maestro que define la red virtual y quién puede entrar en ella.
> - **Peer:** Cada uno de los extremos de la conexión (tu PC del aula y el Servidor en Azure son "Peers").
> - **Endpoint:** La dirección IP pública real del servidor a la que se conecta el túnel.

---

### 🔓 Apertura de Puertos (NSG de Azure)

> [!example] Al empezar: abre el puerto de WireGuard
> Antes de tocar nada en el servidor, abre en Azure el puerto por el que viajará el tráfico VPN. Sin este paso, el túnel no puede establecerse aunque la configuración sea perfecta.
>
> 1. Entra en **portal.azure.com** → tu VM → **`Configuración de red`** → haz clic en el nombre de tu NSG.
> 2. En el menú izquierdo, haz clic en **`Reglas de seguridad de entrada`**.
> 3. Pulsa **`+ Agregar`** y rellena el formulario para la siguiente regla:
>    - **Origen:** `Any`
>    - **Intervalos de puertos de destino:** el número de la columna "Puerto"
>    - **Protocolo:** el de la columna "Protocolo"
>    - **Acción:** `Permitir`
>    - **Prioridad:** el número de la columna "Prioridad"
>    - **Nombre:** el texto de la columna "Nombre"
> 4. Pulsa **`Agregar`** para guardar la regla:
>
> | Prioridad | Nombre | Puerto | Protocolo | Para qué sirve ahora |
> | :--- | :--- | :--- | :--- | :--- |
> | **310** | WireGuard | 51820 | **UDP** | Canal cifrado del túnel VPN entre el aula y el servidor. |
>
> > [!warning] ⚠️ Este puerto es UDP, no TCP
> > Es el error más habitual en esta fase. WireGuard usa UDP porque necesita velocidad, no garantía de orden — igual que una videollamada. Si lo abres como TCP, la VPN no conectará aunque todo lo demás esté perfectamente configurado.

> [!example] Al terminar: cierra el 22 y activa el SSH seguro por el 2222
> Una vez que el túnel VPN funcione y hayas comprobado el `ping 10.0.0.1`, aplica **Zero Trust**: cerramos la puerta pública del servidor y dejamos solo la privada, accesible únicamente desde dentro de la VPN.
>
> **Paso 1 — En el servidor:** cambia el puerto SSH de 22 a 2222:
> ```bash
> sudo nano /etc/ssh/sshd_config
> ```
> Busca la línea `#Port 22`, elimina el `#` y cámbiala a `Port 2222`. Guarda (`Ctrl+O`, `Enter`, `Ctrl+X`) y reinicia el servicio:
> ```bash
> sudo systemctl restart ssh
> ```
>
> **Paso 2 — En el NSG de Azure:** añade el 2222 y elimina el 22:
>
> | Acción | Prioridad | Nombre | Puerto | Protocolo |
> | :--- | :--- | :--- | :--- | :--- |
> | ➕ Añadir | **300** | SSH_VPN | 2222 | TCP |
> | ❌ Eliminar | — | (regla del puerto 22 creada por Azure al inicio) | 22 | TCP |
>
> > [!info] 💡 ¿Por qué cerramos el 22 ahora y no antes?
> > Porque sin VPN activa no habría forma de entrar al servidor. Primero construimos el túnel seguro y lo verificamos, luego cerramos la puerta pública. A partir de este momento **todas tus conexiones SSH van por dentro del túnel VPN**, nunca por la IP pública de Azure:
> > ```bash
> > ssh -p 2222 boochan@10.0.0.1
> > ```

---

### 🛠️ Procedimiento Práctico (BoochanV2)

> [!example] Paso 1: Generación de Llaves Criptográficas del Servidor
> Ejecuta estos comandos en el servidor para generar la identidad digital del servidor.
> *El comando `umask 077` es vital: asegura que nadie más pueda leer tu llave.*
>
> > [!info] 📚 Diccionario de Comandos: Para entender la sintaxis exacta de `wg` y repasar otros comandos de Linux, consulta el [[Diccionario_Comandos_Sistema]].
>
> ```bash
> sudo -i
> cd /etc/wireguard
> umask 077
> wg genkey | tee privatekey | wg pubkey > publickey
> ```
> Ahora **lee y anota** la llave pública del servidor. La necesitarás cuando configures el cliente en el Paso 3:
> ```bash
> # Muestra la llave PÚBLICA del servidor (esta se comparte con el cliente)
> cat /etc/wireguard/publickey
> ```
> Cuando hayas copiado el valor, vuelve al usuario normal:
> ```bash
> exit
> ```
>
> > [!tip] 💡 ¿Qué hace este comando? (La tubería avanzada)
> > - **El Pipe (`|`):** Imagina que es una tubería. La salida de un comando entra directamente al siguiente.
> > - **El comando `tee`:** Es como una **"T"** en una tubería de agua. Permite que los datos sigan su camino por la tubería pero, al mismo tiempo, guarda una copia en un archivo (`privatekey`).
> > - **`umask 077`:** Es como echar la llave a la habitación antes de escribir un secreto. Asegura que solo tú puedas leer las llaves que vas a generar.

> [!example] Paso 2: Configuración del Túnel en el Servidor (`wg0.conf`)
> Crea el archivo `/etc/wireguard/wg0.conf` con el editor `nano`.
>
> > [!info] 📚 Recurso: Si no recuerdas cómo usar este editor, repasa la [[Guía_Editor_Nano]].
>
> ```bash
> sudo nano /etc/wireguard/wg0.conf
> ```
> Escribe este contenido. Sustituye `<CONTENIDO_DE_TU_PRIVATEKEY>` por el valor del archivo `privatekey`:
> ```ini
> [Interface]
> PrivateKey = <CONTENIDO_DE_TU_PRIVATEKEY>
> Address = 10.0.0.1/24
> ListenPort = 51820
>
> [Peer]
> PublicKey = <LLAVE_PÚBLICA_DEL_CLIENTE_AULA>
> AllowedIPs = 10.0.0.2/32
> ```
> Guarda con `Ctrl + O`, `Enter`, `Ctrl + X`. Deja el campo `<LLAVE_PÚBLICA_DEL_CLIENTE_AULA>` como está por ahora; lo completarás en el Paso 4 una vez que generes las llaves del cliente.

> [!example] Paso 3: Instalación y Configuración del Cliente (PC del Aula)
> El túnel VPN necesita dos extremos configurados. Ahora le toca al **PC de tu aula**:
>
> **1. Instala la aplicación WireGuard en tu PC:**
> - **Windows:** Ve a `wireguard.com/install`, descarga el instalador `.exe` y ejecútalo.
> - **Mac:** Búscalo en la App Store buscando "WireGuard" o descárgalo desde `wireguard.com/install`.
>
> **2. Crea un nuevo túnel y obtén las llaves del cliente:**
> - Abre la aplicación WireGuard.
> - Haz clic en **"Agregar túnel"** → **"Crear nuevo túnel vacío"** (en Mac: icono `+`).
> - WireGuard genera automáticamente las llaves del cliente. Verás la **Clave Pública** del cliente en la parte superior del cuadro de configuración.
> - **Copia y anota esa Clave Pública**: la necesitarás en el servidor.
>
> **3. Completa el archivo de configuración del cliente** con este contenido:
> ```ini
> [Interface]
> PrivateKey = <SE_RELLENA_AUTOMÁTICAMENTE_por_WireGuard>
> Address = 10.0.0.2/32
> DNS = 10.0.0.1
>
> [Peer]
> PublicKey = <LLAVE_PÚBLICA_DEL_SERVIDOR_del_Paso_1>
> AllowedIPs = 10.0.0.0/24
> Endpoint = TU_IP_PUBLICA_AZURE:51820
> PersistentKeepalive = 25
> ```
>
> > [!important] 💡 ¿Qué es `PersistentKeepalive`?
> > Azure cierra las conexiones que están inactivas. Este parámetro hace que el cliente envíe un pequeño "pulso" cada 25 segundos para mantener el túnel vivo aunque no haya tráfico real. Sin esta línea, la VPN se desconectaría sola a los pocos minutos.

> [!example] Paso 4: Intercambio de Llaves y Activación
> Vuelve a la sesión SSH del servidor y completa el archivo `wg0.conf` con la llave pública del cliente que anotaste en el Paso 3:
> ```bash
> sudo nano /etc/wireguard/wg0.conf
> ```
> Sustituye `<LLAVE_PÚBLICA_DEL_CLIENTE_AULA>` por la llave pública real de tu PC. Guarda y sal (`Ctrl + O`, `Enter`, `Ctrl + X`).
>
> > [!caution] ⚠️ Atención al Portapapeles (Copia-Pega)
> > Al borrar el texto de ejemplo `<LLAVE...>`, asegúrate de eliminar también los símbolos `<` y `>`. Un espacio extra, un salto de línea invisible o una letra comida arruinará la conexión VPN de forma silenciosa.
> >
> > **Antes de guardar**, verifica que la clave quedó bien pegada ejecutando:
> > ```bash
> > sudo grep PublicKey /etc/wireguard/wg0.conf
> > ```
> > La salida debe ser una sola línea limpia, sin espacios al principio ni al final, parecida a esto:
> > ```
> > PublicKey = aBcDeFgHiJkLmNoPqRsTuVwXyZ1234567890abcde=
> > ```
> > Si ves dos líneas, espacios raros o caracteres `<` o `>` sueltos, vuelve a editar el archivo antes de continuar.
>
> Ahora levanta el túnel en el servidor y hazlo persistente:
> ```bash
> # Levantar el túnel
> sudo wg-quick up wg0
> # Hacerlo persistente al reinicio
> sudo systemctl enable wg-quick@wg0
> ```
>
> **En el PC cliente (aula):** Activa el túnel haciendo clic en el botón **"Activar"** de la aplicación WireGuard.
>
> Verifica que el túnel está activo. En el servidor:
> ```bash
> # Muestra el estado del túnel y los peers conectados
> sudo wg show
> ```
> Y desde el terminal de tu PC del aula:
> ```bash
> # Si recibes respuestas, el túnel funciona correctamente
> ping 10.0.0.1
> ```
>
> > [!important] 🔒 VPN activa: momento de cerrar el servidor
> > El túnel funciona. Ahora es el momento de ejecutar las **dos acciones de seguridad** que dejamos pendientes en la Fase 1: cambiar el puerto SSH a 2222 en el servidor y eliminar la regla del puerto 22 del NSG de Azure. Encuéntralas al final de la Fase 1 en el apartado "Auditoría de Seguridad".
> >
> > A partir de ese momento, **todas tus conexiones SSH usarán este comando** (con la IP de la VPN, no la IP pública de Azure):
> > ```bash
> > ssh -p 2222 boochan@10.0.0.1
> > ```

---

### 🚩 Resolución de Problemas y Evaluación

> [!bug] Troubleshooting (¿No hay conexión?)
> | Problema | Causa Probable | Solución Sugerida |
> | :--- | :--- | :--- |
> | `Address already in use`. | Ya hay otra interfaz VPN activa con esa IP. | Ejecuta `sudo wg-quick down wg0` antes de volver a levantarla. |
> | No hay ping entre 10.0.0.1 y 10.0.0.2. | El puerto 51820 UDP está cerrado en Azure. | Abre el puerto 51820 **UDP** (no TCP) en el NSG de Azure. |
> | WireGuard no conecta pero el puerto está abierto. | Las llaves públicas están intercambiadas incorrectamente. | Verifica que la llave pública del cliente en el servidor y la del servidor en el cliente son exactas. |

> [!help] Preguntas Críticas (Autoevaluación)
> 1. ¿Por qué la llave privada **NUNCA** debe salir de tu servidor ni enviarse por correo?
> 2. ¿Qué ventaja tiene WireGuard sobre protocolos antiguos en términos de rendimiento?
> 3. ¿Para qué sirve el parámetro `AllowedIPs` en la configuración del Peer?
> 4. 🔬 **Reto práctico:** Con el túnel activo, ejecuta `sudo wg show` en el servidor y localiza la línea `latest handshake`. ¿Hace cuántos segundos fue el último intercambio? Ahora desactiva el túnel desde tu PC del aula y vuelve a ejecutar el comando 30 segundos después. ¿Qué cambió en esa línea? ¿Qué te dice eso sobre el estado de la conexión?
> 5. 🔬 **Reto práctico:** Con el túnel WireGuard **desactivado** en tu PC, intenta conectarte al servidor por SSH usando la IP pública de Azure (no la `10.0.0.1`). ¿Puedes entrar? ¿Por qué sí o por qué no? Razona tu respuesta mirando las reglas del NSG que configuraste en esta fase.

---

> [!caution] 🛑 Auditoría y Seguridad (RA.05)
> Las llaves privadas son la **identidad** de tu servidor. Si un atacante las copia, podrá entrar en tu red privada como si fuera tú. **Validación:** El alumno debe demostrar el `ping 10.0.0.1` desde el cliente del aula y el `sudo wg show` en el servidor mostrando el peer conectado.

---

### ✅ Entregables y cierre

> [!abstract] Qué tienes que tener hecho al acabar esta fase
> | Entregable | Dónde vive | Qué debe contener |
> | :--- | :--- | :--- |
> | **Entrada de apuntes** | `00_Apuntes/Trimestre_N/B4_Ubuntu_Nube/v2-fase-3-conectividad-vpn-wireguard.md` | Estructura completa + **respuestas a las Preguntas Críticas y al 🔬 Reto** + **enlace del vídeo** |
> | **Vídeo** | Playlist `B4_Ubuntu_Nube` (No listado) | Nombrado `V2 · Fase 3 — Conectividad VPN (WireGuard)`, con presentación, identidad y timestamps |
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
