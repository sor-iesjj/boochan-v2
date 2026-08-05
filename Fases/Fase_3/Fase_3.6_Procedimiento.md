## Fase 3 · Apartado 6 — 🛠️ Procedimiento práctico

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Conectividad VPN (WireGuard)**
> 🧭 Índice de la fase: [[Fase_3]]
>
> **📍 Cuándo se lee:** **Con la VM delante.** Aquí está el trabajo.

---

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
>
> [Peer]
> PublicKey = <LLAVE_PÚBLICA_DEL_SERVIDOR_del_Paso_1>
> AllowedIPs = 10.0.0.0/24
> Endpoint = TU_IP_PUBLICA_AZURE:51820
> PersistentKeepalive = 25
> ```
>

> > [!danger] 🛑 Aquí NO va todavía una línea `DNS`
> > Verás en muchos manuales una línea `DNS = 10.0.0.1` dentro de `[Interface]`. **Ahora sería un error.**
> >
> > Esa línea le dice al cliente: *"mientras el túnel esté activo, pregunta los nombres al servidor"*. Tiene sentido **a partir de la Fase 4**, cuando el controlador de dominio levante su DNS interno.
> >
> > **Pero hoy, en `10.0.0.1` no hay ningún servidor DNS.** Si la pones y activas el túnel, las consultas se irán a un sitio donde no contesta nadie: **dejarás de navegar mientras la VPN esté conectada**. El síntoma despista — *"activo la VPN y se me cae internet"* — porque nada apunta al fichero que lo causó.
> >
> > La línea se añade en la **Fase 8**, cuando el cliente tenga que resolver nombres del dominio.
> > Detalle: [[Fase_3.7_Resolucion_Problemas]].

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

> [!example] 🔌 Paso 5 — EJERCICIO DE VERIFICACIÓN: qué hace de verdad tu VPN
> Tienes el túnel levantado y `wg show` dice que hay tráfico. Bien. Pero **¿sabes qué hace exactamente esa VPN, y sobre todo qué NO hace?** Vamos a comprobarlo con fuentes externas.
>
> > [!info] Recordatorio: por qué usamos APIs
> > Una **API** es una web hecha para que la consulte un programa: devuelve **datos limpios** en JSON en vez de una página. Un administrador las usa para **comprobar desde fuera lo que desde dentro no puede ver**. La teoría completa está en la práctica **B1.9b** del Bloque 1.
>
> **a) La red del túnel.** Tu túnel es **`10.0.0.0/24`**. Antes de mirar nada, escribe en tu entrada de apuntes cuántos clientes VPN caben en él. Ahora compruébalo:
> ```bash
> curl "https://networkcalc.com/api/ip/10.0.0.0/24"
> ```
>
> **b) Y ahora la pregunta buena: ¿por qué el cliente lleva `/32`?**
> Fíjate en tu configuración: el servidor tiene `Address = 10.0.0.1/24` pero el cliente tiene `Address = 10.0.0.2/32`. **No es un error.** Míralo:
> ```bash
> curl "https://networkcalc.com/api/ip/10.0.0.2/32"
> ```
> ```json
> "subnet_mask": "255.255.255.255",   "network_address": "10.0.0.2",
> "broadcast_address": "10.0.0.2",       "assignable_hosts": 0
> ```
>
> > [!success] 🤔 Léelo y explícalo en el vídeo
> > Una máscara `/32` significa **una sola dirección**: red, broadcast y host son la misma. **Cero hosts asignables.**
> > Traducido: *"yo soy exactamente esta IP y ninguna más"*. Por eso WireGuard usa `/32` en los clientes — cada uno declara **su** dirección exacta, y el servidor sabe sin ambigüedad a quién enviar cada paquete. Si pusieras `/24` en el cliente, estarías diciendo *"yo soy toda la red"*, y el enrutado se rompería.
>
> **c) El experimento que desmonta un mito.** Tu servidor está en la nube y **sí tiene IP pública propia**. Aun así, el resultado de abajo es el mismo: el túnel no cambia por dónde sales tú a Internet.
>
> 1. Con la VPN **desconectada**, en el cliente:
>    ```bash
>    curl "https://api.ipify.org?format=json"
>    ```
>    Anota la IP.
> 2. **Conecta el túnel** y comprueba que funciona: `ping 10.0.0.1`
> 3. Con la VPN **conectada**, repite exactamente el mismo comando.
>
> > [!danger] 🤯 Sale la MISMA IP. Y está bien.
> > Casi todo el mundo cree que "conectarse a una VPN" cambia tu IP pública — es lo que venden los anuncios de NordVPN y compañía. **Tu VPN no hace eso, y es a propósito.**
> >
> > Mira tu configuración: `AllowedIPs = 10.0.0.0/24`. Le has dicho al cliente: *"manda por el túnel **solo** lo que vaya a esa red"*. Todo lo demás —YouTube, Google, ipify— **sigue saliendo por tu conexión normal**. Eso se llama **split tunnel** (túnel partido).
> >
> > | | Qué manda por el túnel | Tu IP pública |
> > | :--- | :--- | :--- |
> > | **Split tunnel** (`AllowedIPs = 10.0.0.0/24`) ← el tuyo | Solo el tráfico hacia el servidor | **No cambia** |
> > | **Full tunnel** (`AllowedIPs = 0.0.0.0/0`) | **Todo** tu tráfico de Internet | Sí: sale la del servidor |
> >
> > **¿Y por qué split y no full?** Porque tu VPN existe para **llegar a tu servidor de forma segura**, no para ocultarte. Si mandaras todo el tráfico por el túnel, cargarías tu servidor con el YouTube de todos los clientes, y si el túnel cae te quedas sin Internet. Un administrador elige *split* salvo que tenga una razón concreta para lo contrario.
>
> > [!question] Lo que va a tu entrada de apuntes
> > 1. ¿Cuántos clientes VPN caben en tu túnel? ¿Coincidió con tu cálculo?
> > 2. ¿Por qué el cliente lleva `/32` y el servidor `/24`? Explícalo con lo que devolvió la API.
> > 3. Tu IP pública **no cambió** al conectar la VPN. **¿Por qué?** ¿Qué habría que cambiar en la configuración para que sí cambiara?
> > 4. Un compañero dice: *"si uso VPN nadie sabe lo que hago en Internet"*. Con lo que acabas de comprobar, **¿tiene razón?**

---

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_3.5_Fundamento_Teorico]] | [[Fase_3]] | [[Fase_3.7_Resolucion_Problemas]] |
