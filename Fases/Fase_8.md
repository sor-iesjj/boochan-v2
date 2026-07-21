## 💻 Fase 8: Integración del Cliente (Windows 11)

### Infraestructura de Servidores Cloud

> **[Módulo: SOR — Sistemas Operativos en Red]**
> **[U.T. 10: Linux como servidor de dominio / Linux como cliente de dominio]**
> **[RA.06]** Realiza tareas de integración de sistemas operativos libres y propietarios.
>
> **Profesor:** Pedro Navarro Miralles  
> **Correo:** p.navarromiralles2@edu.gva.es  
> **Centro:** IES Jorge Juan (ALICANTE)
>
> **⏱️ Tiempo estimado:** ~2 horas (teoría + práctica + retos + troubleshooting)  
> **Requisitos:** Windows 11 | 8-12 GB RAM | VPN activa | Samba completo (Fases 1-7)

---

### 🎯 ¿Dónde Estamos?

> [!info] Vienes de Fase 7
> El servidor Linux es ahora un "reino" completo: dominio, usuarios, grupos, discos protegidos, y permisos granulares. Todo está funcionando perfectamente desde la terminal. Sin embargo, los usuarios del aula están esperando en sus PCs Windows 11 — ahora necesitas que esos equipos confíen en el servidor y usen sus identidades de dominio.

> [!warning] El Problema
> Windows y Linux hablan idiomas diferentes de seguridad. Windows necesita: (1) encontrar el servidor por DNS, (2) sincronizar el reloj exactamente (Kerberos rechaza diferencias > 5 minutos), (3) establecer una "relación de confianza" registrándose en Active Directory, (4) permitir que los usuarios inicien sesión con sus credenciales de dominio. Si algo falla, el usuario ve "No se encuentra el dominio" o "Error de relación de confianza".

> [!success] Objetivo de esta Fase
> **Unir Windows 11 al dominio BOOCHAN.SPACE** de forma que los usuarios puedan iniciar sesión con sus credenciales de dominio (ej. `BOOCHAN\user1`) y acceder a las carpetas compartidas del servidor con los permisos que se les asignaron en Linux. Es el momento de la verdad: la infraestructura híbrida (Linux servidor + Windows cliente) funcionando en sinergia.

> [!tip] Hoja de Ruta
> 1. **Validar VPN:** Activar el túnel WireGuard en el PC del aula para acceder a la red privada 10.0.0.0/24
> 2. **Configurar DNS de Windows:** Cambiar DNS primario a 10.0.0.1 (el servidor), DNS secundario a 8.8.8.8 (fallback a internet)
> 3. **Sincronizar reloj:** Ejecutar `w32tm /resync /force` para emparejar la hora exactamente con el servidor
> 4. **Unir al dominio:** A través de Configuración → Sistema → Acerca de, introducir `BOOCHAN.SPACE` y credenciales de Administrator
> 5. **Reiniciar Windows:** Obligatorio para aplicar los cambios de dominio
> 6. **Primer login:** Iniciar sesión con `BOOCHAN\user1` y su contraseña desde la pantalla de inicio
> 7. **Instalar RSAT:** Herramientas administrativas para gestionar usuarios/grupos desde Windows gráficamente
> 8. **Mapear carpetas de red:** Conectar `\\UbuntuServer.BOOCHAN.SPACE\prueba1` y `prueba3` como unidades de red (Z:, por ejemplo)
>
> **Resultado Final:** Windows 11 es ahora un cliente legítimo del dominio. Los usuarios pueden iniciar sesión, acceder a carpetas según sus permisos de grupo, y crear archivos que el servidor Linux reconoce automáticamente.
> **Siguiente:** Fase completada — el proyecto es funcional de extremo a extremo. Servidor Linux como DC, usuarios en AD, almacenamiento seguro, y clientes Windows integrados.

---

### 📚 Fundamento Teórico

> [!abstract] 1. El Momento de la Verdad
> Unir un Windows 11 al dominio significa que el PC transfiere la autoridad de seguridad al servidor Linux. A partir de ahora, el servidor decidirá quién entra y qué puede hacer.

> [!warning] 2. Sincronización Horaria (NTP)
> Kerberos (el sistema de tickets) utiliza marcas de tiempo para evitar ataques. Si el reloj del PC y el del Servidor varían más de **5 minutos (Clock Skew)**, la comunicación se cortará por seguridad y no podrás iniciar sesión. 

> [!important] 3. DNS: El Guía de la Red
> Windows debe usar el DNS de nuestra VPN (10.0.0.1) para poder encontrar al "Rey" (el Controlador de Dominio). Si usa el DNS del router de casa, jamás encontrará el servidor `BOOCHAN.SPACE`.

### 📖 Diccionario de Conceptos Clave

> [!quote] Integración de Clientes
> - **Unirse al Dominio:** Proceso de registrar un ordenador cliente en la base de datos central del Directorio Activo.
> - **Clock Skew:** El desfase de tiempo máximo permitido por seguridad (300 segundos = 5 minutos).
> - **RSAT:** Herramientas de administración remota para gestionar el dominio Linux desde la interfaz gráfica de Windows.
> - **net use:** Comando de consola para conectar carpetas compartidas como si fueran discos locales.

### 🔓 Apertura de Puertos (NSG de Azure)

> [!info] ℹ️ Sin cambios en el NSG en esta fase
> El cliente Windows se conecta al servidor a través del **túnel VPN (WireGuard)**, no directamente por internet. Todo el tráfico de dominio (Kerberos, LDAP, SMB…) viaja cifrado por dentro del túnel, cuyo puerto (51820 UDP) ya está abierto desde la Fase 3. No tienes que tocar nada en Azure.
>
> **Lo único que debes hacer antes de empezar:** activar el túnel WireGuard en tu PC del aula.

---

### 🛠️ Procedimiento Práctico (CORRECCIÓN CRÍTICA)

> [!important] 🔌 Antes de empezar: Activa la VPN
> Para que Windows pueda encontrar el dominio, **el túnel WireGuard debe estar activo**. Abre la aplicación WireGuard en tu PC y haz clic en **"Activar"** antes de continuar con cualquier paso de esta fase.

> [!example] Paso 1: Configuración del DNS en Windows
> Windows debe preguntar a nuestro servidor (10.0.0.1) para encontrar el dominio. Sigue estos pasos para cambiar el DNS manualmente:
>
> 1. Haz clic en el icono de **Red** de la barra de tareas → **"Configuración de red e Internet"**.
> 2. Haz clic en **"Ethernet"** (o "Wi-Fi" si usas inalámbrico) → **"Editar"** junto a "Asignación de servidor DNS".
> 3. En el desplegable, cambia "Automático (DHCP)" a **"Manual"**.
> 4. Activa el interruptor de **IPv4** e introduce:
>    - **DNS preferido:** `10.0.0.1`
>    - **DNS alternativo:** `8.8.8.8`
> 5. Pulsa **"Guardar"**.
>
> > [!tip] 💡 ¿Por qué ponemos también `8.8.8.8`?
> > Con solo `10.0.0.1`, Windows pierde acceso a internet si el servidor no reenvía consultas al exterior. El `8.8.8.8` (DNS público de Google) actúa de red de seguridad para que Windows pueda seguir navegando y descargando software como RSAT en el Paso 5.
>
> > [!tip] 💡 Verifica que el DNS funciona
> > Abre el Símbolo del sistema (`cmd`) y ejecuta:
> > ```cmd
> > nslookup BOOCHAN.SPACE
> > ```
> > Si devuelve la IP `10.0.0.1`, el DNS está funcionando. Si dice "no se encuentra el servidor", la VPN no está activa o el DNS es incorrecto.

> [!example] Paso 2: Sincronización de Tiempo
> Ejecuta este comando en el **Símbolo del sistema (CMD) como Administrador**:
>
> *(Para abrirlo como Administrador: pulsa `Windows + X` → "Terminal de Windows (Administrador)" o busca "cmd" en el menú inicio, haz clic derecho → "Ejecutar como administrador")*
>
> > [!info] 📚 Diccionario de Comandos: Recuerda que también tienes explicados los comandos vitales de Windows (`w32tm`, `nslookup`) en el [[Diccionario_Comandos_Sistema]].
>
> ```cmd
> w32tm /resync /force
> ```
>
> > [!tip] 💡 ¿Qué hace este comando?
> > - **`w32tm`:** Es la herramienta de gestión del tiempo de Windows. El parámetro `/resync /force` obliga al PC a emparejar su reloj con el del Controlador de Dominio inmediatamente, ignorando cualquier restricción.

> [!example] Paso 3: Unión al Dominio
> 1. Abre **Configuración** (tecla `Windows + I`).
> 2. Ve a **Sistema** → **Acerca de**.
> 3. Haz clic en **"Cambiar nombre de este PC (avanzado)"** → pestaña **"Nombre de equipo"** → botón **"Cambiar..."**.
> 4. Selecciona **"Dominio"** e introduce: `BOOCHAN.SPACE`
> 5. Pulsa **Aceptar**. Te pedirá credenciales: introduce `Administrator` y `P@ssword2026!`.
> 6. Si aparece el mensaje **"Bienvenido al dominio BOOCHAN"**, el proceso ha sido correcto.
> 7. **Reinicia el equipo** cuando te lo pida. Este paso es obligatorio.
>
> > [!important] 💡 El reinicio es obligatorio
> > Sin reiniciar, Windows no aplica los cambios del dominio. Al volver a encender el PC, en la pantalla de inicio de sesión verás la opción de iniciar sesión con un usuario del dominio.

> [!example] Paso 4: Primer Inicio de Sesión con Usuario del Dominio
> > [!caution] ⚠️ La VPN debe estar activa antes de intentar el login
> > Al iniciar sesión con `BOOCHAN\user1`, Windows necesita contactar con el servidor en `10.0.0.1` para validar las credenciales. Si la VPN no está activa, el login fallará con "No se puede contactar con el dominio". Abre la aplicación WireGuard y activa el túnel **antes** de introducir el usuario y la contraseña.
>
> En la pantalla de inicio de sesión de Windows, introduce las credenciales del usuario del dominio. Fíjate en el formato correcto:
>
> - **Usuario:** `BOOCHAN\user1`  *(el nombre del dominio, una barra invertida `\`, y el nombre de usuario)*
> - **Contraseña:** `P@ssword2026!`
>
> > [!warning] ⚠️ La barra invertida `\`, no la barra normal `/`
> > La barra invertida se escribe con la tecla que tiene el símbolo `\` en tu teclado (normalmente junto al `Intro` o junto al `0`). Si usas la barra normal `/`, no funcionará.

> [!example] Paso 5: Instalación de RSAT (Herramientas de Administración)
> RSAT permite gestionar usuarios y grupos del dominio directamente desde Windows, con una interfaz gráfica. Instálalo así:
>
> 1. Ve a **Configuración** → **Aplicaciones** → **Características opcionales**.
> 2. Haz clic en **"Ver características"**.
> 3. Busca `RSAT` en el cuadro de búsqueda.
> 4. Instala **"RSAT: Herramientas de Servicios de dominio de Active Directory y Lightweight Directory"**.
> 5. Pulsa **"Instalar"** y espera a que termine.
>
> Una vez instalado, encontrarás las herramientas buscando **"Usuarios y equipos de Active Directory"** en el menú Inicio.

> [!example] Paso 6: Mapeo de Carpetas de Red
> Con el usuario del dominio iniciado, conecta las carpetas del servidor como si fueran discos locales. Abre el **Símbolo del sistema (CMD)** y ejecuta:
> ```cmd
> net use Z: \\UbuntuServer.BOOCHAN.SPACE\prueba1 /user:BOOCHAN\user1
> ```
>
> > [!tip] 💡 ¿Qué hace este comando?
> > - **`Z:`**: Asigna una letra de unidad libre (como un disco duro más).
> > - **`\\UbuntuServer.BOOCHAN.SPACE\prueba1`**: Es la ruta UNC (la dirección de la carpeta en la red). Usamos el nombre del servidor en lugar de la IP para que Windows use Kerberos (el sistema de tickets seguro) en lugar de un protocolo más antiguo y menos fiable.
> > - **`/user:BOOCHAN\user1`**: Especifica con qué identidad del dominio queremos entrar.

---

### 🚩 Resolución de Problemas y Evaluación

> [!bug] Troubleshooting (¿No puedes unirte?)
> | Problema | Causa Probable | Solución Sugerida |
> | :--- | :--- | :--- |
> | "No se encuentra el dominio". | El cliente está usando el DNS del router, no el nuestro. | Comprueba que el DNS primario es `10.0.0.1` y que la VPN está activa. |
> | "Error de relación de confianza". | Desfase horario (Clock Skew) superior a 5 minutos. | Comprueba la zona horaria en ambos y ejecuta `w32tm /resync /force`. |
> | La unidad `Z:` no aparece al reiniciar. | El mapeo no es persistente. | Añade `/persistent:yes` al final del comando `net use`. Recuerda que la VPN debe estar activa antes de que Windows intente reconectar la unidad. |

> [!help] Preguntas Críticas (Autoevaluación)
> 1. ¿Por qué Windows necesita consultar específicamente el DNS del servidor para unirse al dominio?
> 2. ¿Qué sucede técnica y exactamente si hay más de 5 minutos de diferencia horaria?
> 3. ¿Para qué sirven las herramientas **RSAT** en esta infraestructura híbrida?
> 4. 🔬 **Reto práctico:** Con `user1` iniciado en Windows, crea un archivo de texto en la unidad `Z:` (por ejemplo `prueba_user1.txt`). Sin cerrar Windows, entra al servidor por SSH y ejecuta `ls -la /srv/samba/prueba1/`. ¿Ves el archivo? ¿A qué usuario Linux pertenece según la columna de propietario? ¿Coincide con el UID que configuraste en la Fase 5?
> 5. 🔬 **Reto práctico:** Con `user1` logueado, **desactiva el túnel WireGuard** desde la aplicación sin cerrar sesión de Windows. Intenta abrir un archivo de la unidad `Z:`. ¿Qué error aparece? ¿Qué le dirías a un usuario de empresa que llama al soporte diciendo que "la carpeta compartida ha desaparecido"?

---

> [!caution] 🛑 Auditoría de Integración (RA.06)
> **Validación:** El alumno debe loguearse con `user1` en el Windows 11 del aula y demostrar que puede crear un archivo en la unidad `Z:` que luego sea visible en el servidor Linux con `ls /srv/samba/prueba1`. Además, debe demostrar que `user2` (bomberos) no ve la carpeta `prueba3` en el explorador de archivos.

> [!success] 🏁 Punto de Control (Antes de seguir)
> - [ ] ¿Has podido unirte al dominio sin errores de DNS?
> - [ ] ¿La unidad de red `Z:` aparece en el explorador de archivos?
> - [ ] ¿`user1` puede crear archivos en `Z:` y se ven desde el servidor Linux?
> - [ ] ¿`user2` no ve la carpeta `prueba3` al navegar por la red?
