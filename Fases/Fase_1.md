## 🏗️ Fase 1: Infraestructura Cloud (Azure IaaS)

### Infraestructura de Servidores Cloud

> **[Módulo: SOR — Sistemas Operativos en Red]**
> **[U.T. 1, 2 y 3: Instalación de Sistemas Operativos en Red]**
> **[RA.01]** Instala sistemas operativos en red describiendo sus características e interpretando la documentación técnica.
>
> **Profesor:** Pedro Navarro Miralles  
> **Correo:** p.navarromiralles2@edu.gva.es  
> **Centro:** IES Jorge Juan (ALICANTE)
>
> **⏱️ Tiempo estimado:** ~1,5 horas (teoría + práctica + retos + troubleshooting)  
> **Requisitos:** 2-4 GB RAM | Azure Portal | SSH

---

> [!important] 📹 Obligaciones de grabación (LÉEME — es igual en TODAS las fases)
> Esta práctica se **graba entera con OBS**, de principio a fin. No es un repaso al final: quiero ver **cómo lo haces tú**.
> 1. **Prepárate primero (sin grabar):** comprueba lo necesario, **léete el procedimiento entero** y **crea la entrada de apuntes de esta fase** en Obsidian: fichero `v2-fase-1-infraestructura-cloud-azure-iaas.md` dentro de `00_Apuntes/Trimestre_N/B4_Ubuntu_Nube/`, con la estructura de la Fase 0.1 y **vacía**. Rellenarla es cosa tuya, después.
> 2. **Arranca OBS y PRESÉNTATE:** *"Hola, me llamo [Nombre], 2.º SMR, y en este vídeo voy a explicar la Fase 1 de Boochan V2 — Infraestructura Cloud (Azure IaaS)."* Y **muestra algo que demuestre que eres tú** (tu perfil de GitHub, tu Teams o tu correo `@alu.edu.gva.es`). Di qué vas a hacer.
> 3. **Graba TODO el procedimiento**, explicando cada paso en voz alta mientras lo haces.
> 4. **Timestamps SIEMPRE** en la descripción: `00:00 Presentación` + uno por cada paso.
> 5. **Al terminar:** nombra el vídeo `V2 · Fase 1 — Infraestructura Cloud (Azure IaaS)`, súbelo a tu playlist de YouTube **`B4_Ubuntu_Nube`** (No listado) y **copia su enlace**.
> 6. **~8-10 min.** Esta fase es más larga que las de prerrequisitos: ve al grano, pero no te saltes pasos. Si se te va mucho, **pártela en dos vídeos** y ponlos los dos en la entrada.
> 7. **El enlace del vídeo va DENTRO de tu entrada de apuntes**, en el apartado `Enlace al vídeo explicativo`. Ahí, no en un papel.
> 8. **La entrega va por la TAREA de Teams.** Abriré una tarea que cubrirá **esta fase y otras**; te llegará notificación con fecha límite.

---

### 🎯 ¿Dónde Estamos?

> [!info] El Punto de Partida
> No vienes de una fase anterior — esta es la base. Pero vienes del mundo real: necesitas un servidor que esté **disponible 24/7**, que no dependa de tu ordenador personal, que sea escalable, profesional y seguro.

> [!warning] El Problema
> Instalar un servidor físico en la clase es caro (comprar hardware), requiere mantenimiento constante (electricidad, refrigeración, actualizaciones de seguridad), no es escalable (si necesitas 2 servidores, necesitas 2 máquinas), y es frágil: una inundación, un apagón o un accidente físico lo destruye. La nube resuelve esto.

> [!success] Objetivo de esta Fase
> Crear una **máquina virtual en Azure** que aloje Ubuntu Server LTS. Este servidor será tu controlador de dominio, tu almacenamiento de archivos y la base de toda la infraestructura BoochanV2. Lo protegerás con un **NSG (firewall cloud)** que bloquea internet y abre solo los puertos imprescindibles: 9090 para monitoreo, 22 para administración.

> [!tip] Hoja de Ruta
> 1. Crear una VM en Azure con Ubuntu Server 24.04 LTS (2 GB RAM mínimo)
> 2. Configurar el NSG: abrir puertos 9090 (Cockpit) y 22 (SSH) — nada más
> 3. Conectarse al servidor por SSH desde tu PC (primera vez que entras)
> 4. Verificar acceso a internet y DNS (`curl google.com`)
> 5. Medir RAM base con `free -h` (línea base para comparar en fases futuras)
>
> **Resultado Final:** Un servidor en la nube listo, accesible, aislado.
> **Siguiente:** Fase 2 (Purga y FQDN) — limpiaremos el servidor de software innecesario y le daremos una identidad de dominio (BOOCHAN.SPACE).

---

### 📚 Fundamento Teórico Avanzado

> [!info] ¿Por qué usamos la Nube (IaaS)?
> El concepto de **IaaS (Infraestructura como Servicio)** es el primer pilar de la administración moderna. Tradicionalmente, instalaríamos Ubuntu Server introduciendo un USB en una máquina física en el aula. En este proyecto daremos el salto profesional: en lugar de tocar un ordenador físico, alquilamos recursos en centros de datos masivos.

> [!abstract] 1. La "Magia" del Hipervisor y la Virtualización
> El **Hipervisor** es una capa de software de bajo nivel que gestiona los recursos de un servidor físico real y te entrega una porción exacta de CPU, RAM y disco. 
> - **Tu servidor:** Cree que es un ordenador físico completo.
> - **La Realidad:** Es un archivo ejecutándose dentro de otro ordenador gigante. Esto permite que un solo superordenador de Azure albergue cientos de servidores de alumnos de forma aislada.

> [!warning] 2. El Modelo de Responsabilidad Compartida
> Trabajar en la nube no significa que "todo es mágico y seguro". Azure funciona bajo este modelo:
> *   **Responsabilidad de Microsoft:** Seguridad física (evitar robos de discos), electricidad y conexión a Internet.
> *   **Tu Responsabilidad (El Administrador):** Eres el responsable absoluto de lo que ocurre **dentro** de tu máquina virtual. Si configuras mal una contraseña o dejas un puerto abierto, los hackers entrarán. ¡Microsoft no te protegerá de tus propios errores de configuración!

> [!important] 3. Arquitectura Cliente-Servidor "Headless" (Sin Cabeza)
> Vamos a desplegar un servidor **"Headless"**. Esto significa que no tiene entorno gráfico (ni escritorio, ni ratón, ni ventanas). Lo controlamos 100% mediante comandos de texto (CLI).
> *   **¿Por qué?** Porque los entornos gráficos consumen mucha memoria RAM (la "mesa de trabajo" del PC). Un servidor debe dedicar el 100% de sus recursos a dar servicio, no a dibujar iconos. 
> *   **Seguridad:** Cada programa instalado (como un navegador) es una puerta potencial para un hacker. Al eliminar la interfaz gráfica, reducimos las "puertas" y blindamos el sistema.

> [!note] 4. Seguridad Perimetral y Protocolos (TCP vs UDP)
> Antes de encender el servidor, lo protegemos con un **NSG (Network Security Group)**, que actúa como la muralla del castillo. Solo abriremos las "puertas" (puertos) necesarias usando estos protocolos:
> *   **TCP (Transmission Control Protocol):** Para administrar el servidor (SSH) y archivos (SMB). TCP exige confirmación de entrega. Si un dato se pierde, se vuelve a pedir. Es **fiable pero más lento**.
> *   **UDP (User Datagram Protocol):** Para la VPN (WireGuard) y la hora (NTP). UDP dispara los paquetes a máxima velocidad sin preguntar nada. Es **rapidísimo pero menos fiable**.

### 📖 Diccionario de Conceptos Clave

> [!quote] Terminología Profesional (Para no perderse)
> - **Instancia:** Una máquina virtual activa y ejecutándose en la nube.
> - **Provisionamiento:** El proceso de preparar y equipar un servidor con todo lo necesario para funcionar.
> - **NSG (Network Security Group):** Un firewall o muro lógico que decide qué tráfico de Internet entra a tu servidor.
> - **LTS (Long Term Support):** Versión de software con actualizaciones de seguridad garantizadas durante 5 años.

---

### 🛠️ Procedimiento Práctico (BoochanV2)

> [!example] 🎬 Antes de empezar (todavía SIN grabar, y luego arranca)
> Ya conoces el método desde los prerrequisitos, así que va solo el recordatorio:
> 1. **Crea la entrada de apuntes** de esta fase (`v2-fase-1-infraestructura-cloud-azure-iaas.md`) con su estructura, vacía.
> 2. **Léete los 3 pasos** del procedimiento enteros, para no atascarte a mitad del vídeo.
> 3. Ten **OBS** listo y comprueba **pantalla y micrófono**.
>
> Cuando lo tengas: **arranca la grabación, preséntate y muestra tu identidad**. A partir de ahí, **todo queda grabado** — incluido cualquier paso previo de preparación que venga a continuación.

> [!example] Paso 1: Creación de la Máquina Virtual en Azure
> Entra en **portal.azure.com** con las credenciales que te haya proporcionado tu profesor(identidad digital del alumno). Una vez dentro:
>
> 1. En la **barra de búsqueda** superior, escribe `Máquinas virtuales` y haz clic en el primer resultado.
> 2. Pulsa el botón **`+ Crear`** → **`Máquina virtual de Azure`**.
> 3. Rellena el formulario con exactamente estos valores:
>
> | Campo | Valor |
> | :--- | :--- |
> | **Grupo de recursos** | Crea uno nuevo → `rg-boochan-[tunombre]` |
> | **Nombre de la máquina virtual** | `UbuntuServer` |
> | **Región** | La que indique tu profesor |
> | **Imagen** | `Ubuntu Server 22.04 LTS - x64 Gen2` |
> | **Tamaño** | `Standard_B2s` (2 vCPUs, 4 GB RAM) |
> | **Tipo de autenticación** | `Contraseña` |
> | **Nombre de usuario** | `boochan` |
> | **Contraseña** | `P@ssword2026!` *(¡anótala!)* |
>
> 4. En la pestaña **`Redes`**, deja todos los valores por defecto. Azure crea automáticamente la red y un NSG básico con el puerto SSH (22) ya abierto.
> 5. Pulsa **`Revisar y crear`** y luego **`Crear`**. Espera 2-3 minutos hasta que el despliegue termine.
>
> > [!important] 💡 ¿Qué es el "Grupo de Recursos"?
> > Piensa en él como una **carpeta de proyecto**. Agrupa todos los componentes de tu servidor (la VM, el disco duro, la red...) para que al final del curso puedas borrarlos todos juntos con un solo clic, evitando costes innecesarios.

> [!example] Paso 2: Configuración del Cortafuegos Perimetral (NSG)
> Con la VM ya creada, añadimos las reglas de seguridad que protegerán el servidor durante todo el proyecto:
>
> 1. En el panel de tu VM, haz clic en **`Configuración de red`** en el menú izquierdo.
> 2. Haz clic en el nombre de tu NSG (aparece como un enlace azul).
> 3. En el menú izquierdo del NSG, haz clic en **`Reglas de seguridad de entrada`**.
> > [!warning] ⚠️ ¡NO borres el Puerto 22 por defecto!
> > Al desplegar la máquina, Azure creó una regla automática permitiendo el puerto 22. **No la borres todavía.** Aunque la tabla de abajo te pida crear una regla para el `2222` (para el futuro), en esta fase inicial nos conectaremos usando el 22. Si lo borras ahora, te quedarás fuera de tu propio servidor y no podrás avanzar.
>
> 4. Pulsa **`+ Agregar`** y, para **cada fila** de la tabla siguiente, rellena el formulario así:
>    - **Origen:** `Any`
>    - **Intervalos de puertos de destino:** el número de la columna "Puerto"
>    - **Protocolo:** TCP según la tabla
>    - **Acción:** `Permitir`
>    - **Prioridad:** el número de la columna "Prioridad"
>    - **Nombre:** el texto de la columna "Nombre"
> 5. Pulsa **`Agregar`** después de cada regla:
>
> | Prioridad | Nombre | Puerto | Protocolo | Para qué sirve ahora |
> | :--- | :--- | :--- | :--- | :--- |
> | **100** | Cockpit | 9090 | TCP | Panel web de monitorización visual del servidor. |
> | **200** | SSH | 22 | TCP | Acceso remoto para administrar el servidor desde el aula. |
>
> > [!info] 💡 ¿Por qué solo dos puertos de momento?
> > Con estos dos puertos puedes entrar al servidor y ver su estado. El resto de puertos (VPN, dominio, carpetas compartidas...) los abriremos en cada fase cuando instalemos el servicio correspondiente. Así nunca abrimos una puerta sin saber para qué sirve.
>
> > [!warning] ⚠️ El puerto 22 es provisional
> > En la **Fase 3**, cuando la VPN esté funcionando, cerraremos el puerto 22 al mundo exterior y usaremos el 2222 solo desde dentro de la red privada. Por ahora lo dejamos en 22 porque sin VPN no podríamos entrar al servidor.

> [!example] Paso 3: Primera Conexión al Servidor (SSH)
> Vuelve al panel principal de tu VM y localiza el campo **`Dirección IP pública`**. **Anótala**: la necesitarás en todas las fases del proyecto.
>
> Abre una terminal en tu ordenador:
> - **Windows:** Pulsa `Windows + R`, escribe `cmd` y pulsa Enter.
> - **Mac / Linux:** Abre la aplicación `Terminal`.
>
> Escribe este comando sustituyendo `TU_IP_PUBLICA` por la IP que anotaste:
> ```bash
> ssh boochan@TU_IP_PUBLICA
> ```
> La primera vez verás un mensaje de advertencia sobre la autenticidad del servidor. Escribe `yes` y pulsa Enter. A continuación escribe tu contraseña (`P@ssword2026!`).
>
> > [!warning] ⚠️ La contraseña no se ve mientras la escribes
> > En Linux y en SSH, cuando introduces una contraseña el cursor no se mueve y no aparecen asteriscos. Es una medida de seguridad normal. Escríbela y pulsa Enter.
>
> Si al final ves algo parecido a `boochan@UbuntuServer:~$`, **ya estás dentro de tu servidor**. A partir de aquí, todo lo que escribas se ejecuta en Azure.
>
> > [!tip] 💡 ¿Qué es SSH?
> > SSH (Secure Shell) es como un **"mando a distancia" cifrado** para tu servidor. Desde el teclado de tu PC del aula estás enviando comandos que se ejecutan en el ordenador de Azure, a cientos de kilómetros. Todo el tráfico viaja cifrado para que nadie pueda interceptar lo que escribes.
>
> > [!important] 💡 El puerto 22 y el 2222
> > Ahora nos conectamos por el puerto 22, que es el que Azure abre por defecto al crear la VM. En la **Fase 3**, una vez configurada la VPN, cambiaremos SSH al puerto 2222 para mayor seguridad. El NSG ya tiene esa regla preparada en la tabla de arriba.

> [!tip] 💡 ¿Cómo verifico si los puertos están "vivos"?
> Una vez que tengas servicios corriendo en las siguientes fases, puedes usar este comando para ver qué puertos están escuchando en tu servidor:
> ```bash
> # -t: TCP, -u: UDP, -l: En escucha (listening), -n: Muestra números de puerto
> sudo ss -tulpn
> ```

---

### 🚩 Resolución de Problemas y Evaluación

> [!bug] Tabla de Troubleshooting (¿Algo no funciona?)
> | Problema | Causa Probable | Solución Sugerida |
> | :--- | :--- | :--- |
> | No puedo conectar por SSH ("Connection refused"). | La VM no ha terminado de arrancar. | Espera 2-3 minutos y vuelve a intentarlo. |
> | SSH se conecta pero pide contraseña en bucle. | La contraseña es incorrecta. | Comprueba que no tienes el Bloq Mayús activado. |
> | El servidor **no responde al ping**. | El protocolo ICMP está bloqueado por defecto en Azure. | Es normal por seguridad. No abras el ping; usa `telnet` o `nc` para probar puertos TCP. |

> [!help] Preguntas Críticas (Autoevaluación del alumno)
> 1. ¿Por qué Microsoft Azure es responsable del hardware pero tú eres el responsable del Sistema Operativo?
> 2. ¿Qué ocurre exactamente si dejas el puerto de administración abierto a **"Cualquiera" (0.0.0.0/0)**?
> 3. ¿Por qué usamos el puerto 2222 en lugar del estándar 22 para SSH?
> 4. 🔬 **Reto práctico:** Entra en el NSG de Azure y **deshabilita** temporalmente la regla del puerto 9090 (sin borrarla, solo desactívala). Luego intenta abrir Cockpit desde el navegador. ¿Qué ocurre? Vuelve a habilitarla. ¿Qué has comprobado con este experimento sobre el papel del NSG?
> 5. 🔬 **Reto práctico:** Ejecuta `free -h` en el servidor. Anota cuánta RAM está libre ahora, con el sistema base sin servicios. Guarda ese dato — lo compararás con la Fase 4, cuando Samba AD DC esté corriendo, para ver cuánta RAM consume el dominio.

---

> [!caution] 🛑 Auditoría de Seguridad — Tarea pendiente tras la Fase 3
> Una vez que la VPN esté funcionando, realizarás dos acciones para cerrar el servidor al mundo exterior. **No las hagas ahora**: sin VPN activa te quedarías sin acceso.
>
> **Acción 1 — Cambiar el puerto SSH de 22 a 2222 en el servidor:**
> ```bash
> sudo nano /etc/ssh/sshd_config
> ```
> Busca la línea `#Port 22`, elimina el `#` y cambia el número a `2222`. Guarda y reinicia el servicio:
> ```bash
> sudo systemctl restart ssh
> ```
> A partir de aquí, conéctate siempre con:
> ```bash
> ssh -p 2222 boochan@10.0.0.1
> ```
>
> **Acción 2 — Cerrar el puerto 22 en el NSG de Azure:**
> Vuelve a **Configuración de red** → NSG → **Reglas de seguridad de entrada**. Localiza la regla del puerto 22 que Azure creó por defecto y **elimínala**. El puerto 2222 ya está abierto desde el paso 2 de esta fase.
>
> Esto es aplicar seguridad "Zero Trust": nadie en Internet puede llegar al servidor; solo quien esté dentro de la VPN.

---

### ✅ Entregables y cierre

> [!abstract] Qué tienes que tener hecho al acabar esta fase
> | Entregable | Dónde vive | Qué debe contener |
> | :--- | :--- | :--- |
> | **Entrada de apuntes** | `00_Apuntes/Trimestre_N/B4_Ubuntu_Nube/v2-fase-1-infraestructura-cloud-azure-iaas.md` | Estructura completa + **respuestas a las Preguntas Críticas y al 🔬 Reto** + **enlace del vídeo** |
> | **Vídeo** | Playlist `B4_Ubuntu_Nube` (No listado) | Nombrado `V2 · Fase 1 — Infraestructura Cloud (Azure IaaS)`, con presentación, identidad y timestamps |
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
