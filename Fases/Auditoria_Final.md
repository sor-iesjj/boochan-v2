## 🛡️ Auditoría Final y Hardening (Cierre de Seguridad)

> **[RA.06]** Diseña e implementa soluciones de seguridad perimetral y auditoría de sistemas.

### 📚 Fundamento Teórico: El Principio de "Zero Trust"

Para terminar el proyecto, debemos aplicar la filosofía **Zero Trust** (Confianza Cero). Hasta ahora, hemos dejado algunos puertos abiertos a todo Internet para facilitar la configuración inicial. Un administrador profesional, una vez terminado el trabajo, debe "cerrar el castillo" y solo permitir el paso a quien esté dentro de la muralla (la VPN).

### 📖 Diccionario de Conceptos Clave

- **Hardening:** El proceso de "endurecer" un servidor eliminando servicios innecesarios y cerrando puertos.
- **Whitelist (Lista Blanca):** Configuración que bloquea todo por defecto y solo permite el paso a IPs específicas.
- **Zero Trust:** Estrategia de seguridad que asume que la red ya está comprometida y exige verificación constante.

---

> [!important] 📹 Obligaciones de grabación (LÉEME — es igual en TODAS las fases)
> Esta práctica se **graba entera con OBS**, de principio a fin. No es un repaso al final: quiero ver **cómo lo haces tú**.
> 1. **Prepárate primero (sin grabar):** comprueba lo necesario, **léete el procedimiento entero** y **crea la entrada de apuntes de esta fase** en Obsidian: fichero `v2-auditoria-final-hardening-y-cierre-de-seguridad.md` dentro de `00_Apuntes/Trimestre_N/B4_Ubuntu_Nube/`, con la estructura del **Bloque 0 · Fase 0.1.b** y **vacía**. Rellenarla es cosa tuya, después.
> 2. **Arranca OBS y PRESÉNTATE:** *"Hola, me llamo [Nombre], 2.º SMR, y en este vídeo voy a explicar la Auditoría Final de Boochan V2 — Hardening y cierre de seguridad."* Y **muestra algo que demuestre que eres tú** (tu perfil de GitHub, tu Teams o tu correo `@alu.edu.gva.es`). Di qué vas a hacer.
> 3. **Graba TODO el procedimiento**, explicando cada paso en voz alta mientras lo haces.
> 4. **Timestamps SIEMPRE** en la descripción: `00:00 Presentación` + uno por cada paso.
> 5. **Al terminar:** nombra el vídeo `V2 · Auditoría Final — Hardening y cierre de seguridad`, súbelo a tu playlist de YouTube **`B4_Ubuntu_Nube`** (No listado) y **copia su enlace**.
> 6. **~8-10 min.** Esta fase es más larga que las de prerrequisitos: ve al grano, pero no te saltes pasos. Si se te va mucho, **pártela en dos vídeos** y ponlos los dos en la entrada.
> 7. **El enlace del vídeo va DENTRO de tu entrada de apuntes**, en el apartado `Enlace al vídeo explicativo`. Ahí, no en un papel.
> 8. **La entrega va por la TAREA de Teams.** Abriré una tarea que cubrirá **esta fase y otras**; te llegará notificación con fecha límite.

---

### 🛠️ Procedimiento Práctico de Hardening

> [!example] 🎬 Antes de empezar (todavía SIN grabar, y luego arranca)
> Ya conoces el método desde los prerrequisitos, así que va solo el recordatorio:
> 1. **Crea la entrada de apuntes** de esta fase (`v2-auditoria-final-hardening-y-cierre-de-seguridad.md`) con su estructura, vacía.
> 2. **Léete los 2 pasos** del procedimiento enteros, para no atascarte a mitad del vídeo.
> 3. Ten **OBS** listo y comprueba **pantalla y micrófono**.
>
> Cuando lo tengas: **arranca la grabación, preséntate y muestra tu identidad**. A partir de ahí, **todo queda grabado** — incluido cualquier paso previo de preparación que venga a continuación.

> [!example] Paso 1: Cierre de Puertos en Azure
> Ve al portal de **Azure -> Network Security Group (NSG)** y modifica las siguientes reglas para aplicar la máxima seguridad:
> 1.  **Puerto 2222 (SSH):** Cambia el ORIGEN de `Any` a `IP Address` e introduce el rango de tu VPN: `10.0.0.0/24`.
> 2.  **Puerto 445 (SMB):** Cambia el ORIGEN de `Any` a `IP Address` e introduce `10.0.0.0/24`.
> 
> *Resultado: A partir de ahora, nadie en Internet podrá siquiera intentar atacar estos puertos. Solo los alumnos conectados a la VPN podrán administrar el servidor.*

> [!example] Paso 2: Auditoría Local de Servicios
> Ejecuta este comando en la terminal de tu servidor para verificar que no hay "polizontes" o servicios desconocidos:
> ```bash
> # Listar procesos que escuchan en red con su nombre
> sudo ss -tunlp
> ```
> 
> > [!tip] 💡 ¿Qué hace este comando?
> > - **`-t -u`:** Muestra puertos TCP y UDP.
> > - **`-n`:** Muestra números de puerto en lugar de nombres de servicio.
> > - **`-l`:** Solo muestra puertos que están en escucha (*listening*).
> > - **`-p`:** Muestra el nombre del proceso (ej. `smbd`, `winbind`) que es dueño de ese puerto.

---

### ❓ Preguntas Críticas de Cierre
1. ¿Por qué es más seguro permitir el acceso SSH solo a través de la IP de la VPN que dejarlo abierto a todo Internet?
2. ¿Qué ventaja tiene cambiar el origen del tráfico en el NSG de Azure en lugar de usar un firewall interno como `ufw`?
3. Si después de cerrar los puertos ya no puedes conectar por SSH, ¿qué es lo primero que deberías comprobar en tu cliente VPN?
4. ¿Qué significa que un servidor esté "bastionado" (*Hardened*)?
5. ¿Qué proceso es el dueño del puerto 445 según el comando `ss -tunlp`?

---

> [!success] 🏁 Proyecto Finalizado
> ¡Enhorabuena! Has construido una infraestructura híbrida profesional, segura y escalable. Has pasado de tener un servidor vacío a un Controlador de Dominio con cuotas de disco, seguridad ACL invisible y clientes Windows integrados bajo un túnel cifrado WireGuard.

---

### ✅ Entregables y cierre

> [!abstract] Qué tienes que tener hecho al acabar esta fase
> | Entregable | Dónde vive | Qué debe contener |
> | :--- | :--- | :--- |
> | **Entrada de apuntes** | `00_Apuntes/Trimestre_N/B4_Ubuntu_Nube/v2-auditoria-final-hardening-y-cierre-de-seguridad.md` | Estructura completa + **respuestas a las Preguntas Críticas y al 🔬 Reto** + **enlace del vídeo** |
> | **Vídeo** | Playlist `B4_Ubuntu_Nube` (No listado) | Nombrado `V2 · Auditoría Final — Hardening y cierre de seguridad`, con presentación, identidad y timestamps |
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
