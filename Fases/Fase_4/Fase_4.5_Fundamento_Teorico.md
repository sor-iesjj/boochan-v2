## Fase 4 · Apartado 5 — 📚 Fundamento teórico

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Aprovisionamiento del Dominio (Samba AD DC)**
> 🧭 Índice de la fase: [[Fase_4]]
>
> **📍 Cuándo se lee:** **Antes de teclear.** Los conceptos que necesitas.

---

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

> [!example] 🎬 Antes de empezar (todavía SIN grabar, y luego arranca)
> Ya conoces el método desde los prerrequisitos, así que va solo el recordatorio:
> 1. **Crea la entrada de apuntes** de esta fase (`b4-azure-4-aprovisionamiento-del-dominio-samba-ad-dc.md`) con su estructura, vacía.
> 2. **Léete los 3 pasos** del procedimiento enteros, para no atascarte a mitad del vídeo.
> 3. Ten **OBS** listo y comprueba **pantalla y micrófono**.
>
> Cuando lo tengas: **arranca la grabación, preséntate y muestra tu identidad**. A partir de ahí, **todo queda grabado** — incluido cualquier paso previo de preparación que venga a continuación.

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

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_4.4_Donde_Estamos]] | [[Fase_4]] | [[Fase_4.6_Procedimiento]] |
