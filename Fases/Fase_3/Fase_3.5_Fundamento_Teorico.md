## Fase 3 · Apartado 5 — 📚 Fundamento teórico

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Conectividad VPN (WireGuard)**
> 🧭 Índice de la fase: [[Fase_3]]
>
> **📍 Cuándo se lee:** **Antes de teclear.** Los conceptos que necesitas.

---

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

> [!example] 🎬 Antes de empezar (todavía SIN grabar, y luego arranca)
> Ya conoces el método desde los prerrequisitos, así que va solo el recordatorio:
> 1. **Crea la entrada de apuntes** de esta fase (`b4-azure-3-conectividad-vpn-wireguard.md`) con su estructura, vacía.
> 2. **Léete los 5 pasos** del procedimiento enteros, para no atascarte a mitad del vídeo.
> 3. Ten **OBS** listo y comprueba **pantalla y micrófono**.
>
> Cuando lo tengas: **arranca la grabación, preséntate y muestra tu identidad**. A partir de ahí, **todo queda grabado** — incluido cualquier paso previo de preparación que venga a continuación.

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

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_3.4_Donde_Estamos]] | [[Fase_3]] | [[Fase_3.6_Procedimiento]] |
