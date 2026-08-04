## Fase 1 · Apartado 6 — 🛠️ Procedimiento práctico

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Infraestructura Cloud (Azure IaaS)**
> 🧭 Índice de la fase: [[Fase_1]]
>
> **📍 Cuándo se lee:** **Con la VM delante.** Aquí está el trabajo.

---

> [!example] 🎬 Antes de empezar (todavía SIN grabar, y luego arranca)
> Ya conoces el método desde los prerrequisitos, así que va solo el recordatorio:
> 1. **Crea la entrada de apuntes** de esta fase (`v2-fase-1-infraestructura-cloud-azure-iaas.md`) con su estructura, vacía.
> 2. **Léete los 4 pasos** del procedimiento enteros, para no atascarte a mitad del vídeo.
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
> | **Imagen** | `Ubuntu Server 26.04 LTS - x64 Gen2` (ver aviso debajo de la tabla) |
> | **Tamaño** | `Standard_B2s` (2 vCPUs, 4 GB RAM) |
> | **Tipo de autenticación** | `Contraseña` |
> | **Nombre de usuario** | `boochan` |
> | **Contraseña** | `P@ssw0rd.SOR.2026` *(¡anótala!)* |
>
> 4. En la pestaña **`Redes`**, deja todos los valores por defecto. Azure crea automáticamente la red y un NSG básico con el puerto SSH (22) ya abierto.
> 5. Pulsa **`Revisar y crear`** y luego **`Crear`**. Espera 2-3 minutos hasta que el despliegue termine.
>
> > [!warning] ⚠️ Dos avisos sobre esta pantalla: la imagen y la contraseña
> > **1. El nombre exacto de la imagen.** En la tabla pone `Ubuntu Server 26.04 LTS - x64 Gen2`, pero Azure **cambia la redacción de sus imágenes cada pocos meses** (a veces añade el nombre del publicador, a veces cambia "Gen2" de sitio). Busca `Ubuntu Server 26.04` en el desplegable y **coge la LTS de 64 bits que aparezca**, aunque el texto no coincida palabra por palabra con lo que pone aquí. Si solo te aparece otra versión LTS, avisa al profesor antes de seguir.
> >
> > **2. Aquí NO vale el `P@ssw0rd` del resto del módulo.** En las máquinas locales usamos `P@ssw0rd`. Azure la rechaza por dos motivos a la vez: el portal exige **entre 12 y 72 caracteres** (`P@ssw0rd` tiene 8), y además mantiene una **lista negra de las contraseñas más usadas del mundo**, en la que `P@ssw0rd` está de las primeras. Por eso aquí es `P@ssw0rd.SOR.2026`.
> >
> > La lección real: la contraseña que es aceptable en tu portátil aislado **deja de serlo en cuanto la máquina tiene IP pública**, y el proveedor te lo impone aunque tú no quieras.
> >
> > ⚠️ **No la confundas con la del dominio.** Esta es la del usuario `boochan` de la VM. La del **Administrator del dominio** (Fase 4 en adelante) sigue siendo `P@ssw0rd`, porque ahí manda la política de Active Directory, no la de Azure. **Son dos. Anota las dos.**
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
> La primera vez verás un mensaje de advertencia sobre la autenticidad del servidor. Escribe `yes` y pulsa Enter. A continuación escribe tu contraseña (`P@ssw0rd.SOR.2026`).
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

> [!example] 🔌 Paso 4 — EJERCICIO DE VERIFICACIÓN: comprueba tu red desde fuera
> Hasta aquí has configurado la red **y has confiado en que el panel dice la verdad**. Ahora vas a comprobarlo con fuentes **externas e independientes**, que es como se hace de verdad.
>
> > [!info] ¿Qué es una API y por qué la usa un administrador?
> > Una **API** es una web hecha para que la consulte un programa en vez de una persona: en vez de devolverte una página con colores, te devuelve **datos limpios** en formato JSON.
> >
> > ¿Y para qué la quiere un administrador de sistemas? Para **comprobar desde fuera lo que desde dentro no puede ver**. Tu servidor te dirá siempre lo que él cree de sí mismo; un servicio externo te dice **lo que se ve realmente**. Y esa diferencia, cuando aparece, es justo donde está el problema que llevas dos horas buscando.
> >
> > Se consultan con **`curl`**, que ya has usado y que viene instalado en todas partes. Sin programar y sin instalar nada.
>
> **a) Verifica tu cálculo de subred.** Tu red es **`10.0.0.0/24`** (la red virtual (VNet) de Azure).
> Primero, **a mano y sin ayuda**, escribe en tu entrada de apuntes: máscara decimal, dirección de red, broadcast, número de hosts asignables, primero y último.
> Ahora compruébalo:
> ```bash
> curl "https://networkcalc.com/api/ip/10.0.0.0/24"
> ```
> Si no coincide, **no borres tu respuesta**: déjala y explica en el vídeo dónde te equivocaste. Eso enseña más que acertar.
>
> **b) Tu servidor SÍ tiene IP pública. Averigua de quién es.** Desde dentro del servidor:
> ```bash
> curl "https://api.ipify.org?format=json"
> ```
> Compárala con la que te muestra el panel de Azure: **tienen que coincidir**.
>
> Ahora pregunta **quién es el dueño de esa IP**:
> ```bash
> curl "http://ip-api.com/json/TU_IP_PUBLICA?fields=query,country,isp,org,as"
> ```
>
> > [!success] 🤔 Mira bien la respuesta
> > No sale tu nombre: sale **Microsoft**, con su número de **AS** y el país del centro de datos.
> > **Eso es "estar en la nube"**, dicho con datos: tu servidor vive dentro de la infraestructura de Microsoft, y para el resto de Internet es una máquina más de las suyas.
> > **Explica en el vídeo:** ¿en qué país está físicamente tu servidor? ¿Coincide con el que elegiste al crearlo?
>
> > [!question] Lo que va a tu entrada de apuntes
> > 1. ¿Coincidió tu cálculo de subred con el de la API? Si no, ¿en qué fallaste?
> > 2. ¿Cuál es la IP privada de tu servidor y cuál la pública? ¿Por qué no son la misma?
> > 3. ¿Por qué una comprobación hecha **desde el propio servidor** vale menos que una hecha desde fuera?
>
> > [!note] 📌 Para saber más
> > La teoría completa de esto está en la práctica **B1.9b — Verificar tu red con APIs públicas** del Bloque 1. Aquí lo aplicas a tu servidor de verdad.
> > Y una consecuencia que conviene que asumas ya: **tu servidor es alcanzable desde cualquier punto del planeta.** En cuanto lo enciendes empieza a recibir intentos de conexión de desconocidos. Por eso las siguientes fases dedican tanto tiempo al cortafuegos y a la VPN.

---

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_1.5_Fundamento_Teorico]] | [[Fase_1]] | [[Fase_1.7_Resolucion_Problemas]] |
