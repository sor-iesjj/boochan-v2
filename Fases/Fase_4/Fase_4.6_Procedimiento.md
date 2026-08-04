## Fase 4 · Apartado 6 — 🛠️ Procedimiento práctico

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Aprovisionamiento del Dominio (Samba AD DC)**
> 🧭 Índice de la fase: [[Fase_4]]
>
> **📍 Cuándo se lee:** **Con la VM delante.** Aquí está el trabajo.

---

> [!example] Paso 1: Descarga del Proyecto y Ejecución del Script
> Para evitar errores humanos, usaremos el script `provision_boochan.sh`. Primero, descargamos el proyecto completo desde el repositorio usando `git`:
>
> > [!info] 📚 Diccionario de Comandos: Consulta el [[Diccionario_Comandos_Sistema]] para entender al detalle cómo funcionan los comandos administrativos que usaremos aquí.
>
> ```bash
> # Instala git si no lo tienes aún
> sudo apt install git -y
> # Descarga el repositorio del proyecto en la carpeta /opt/boochan
> sudo git clone https://github.com/sor-iesjj/bloque-4-ubuntu-nube-azure /opt/boochan
> # Entra en la carpeta descargada
> cd /opt/boochan
> # Dale permiso de ejecución al script y ejecútalo
> sudo chmod +x provision_boochan.sh
> sudo ./provision_boochan.sh
> ```

>
> El script tardará **2-3 minutos**. Verás mensajes de progreso en pantalla.
>
> > [!tip] 💡 El script escribe mucho en pantalla — ¿cómo sé si va bien?
> > Es normal ver líneas de color amarillo o incluso algún aviso en rojo durante el proceso: son mensajes informativos de Samba, no errores reales. Solo hay que preocuparse si el script **se detiene antes de terminar** sin mostrar el mensaje final. La línea que confirma que todo ha ido bien es:
> > ```
> > Despliegue de BOOCHAN finalizado
> > ```
> > Si no aparece esa línea, el script falló. Revisa la tabla de troubleshooting al final de esta fase.
>
> > [!tip] 💡 ¿Qué hace este comando?
> > - **`git clone`:** Descarga una copia completa del proyecto desde internet a tu servidor, igual que descargar un ZIP pero de forma más profesional.
> > - **`chmod +x`:** En Linux, los archivos descargados no "tienen permiso" para ejecutarse por seguridad. Este comando le pone la etiqueta de **ejecutable**.
> > - **El punto y la barra (`./`):** Le dice a Linux: "Busca este archivo **aquí mismo**, en esta carpeta". Sin el `./`, Linux buscaría el comando en las carpetas del sistema y no lo encontraría.
> > - **Los valores por defecto del script:** El script ya viene configurado con los valores correctos del proyecto (`BOOCHAN.SPACE`, contraseña `P@ssw0rd`). No necesitas modificar nada salvo que tu profesor indique lo contrario.

> [!example] Paso 2: Verificación de Servicios
> Una vez finalizado el script, debemos comprobar que el "corazón" del dominio está latiendo:
> ```bash
> # Comprobar que el servicio está activo y corriendo
> sudo systemctl status samba-ad-dc
> ```

> [!example] Paso 3: Verificación del DNS
> Es vital confirmar que el servidor se mira a sí mismo para resolver nombres de red:
> ```bash
> # Debe devolver: nameserver 127.0.0.1
> cat /etc/resolv.conf
> ```

---

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_4.5_Fundamento_Teorico]] | [[Fase_4]] | [[Fase_4.7_Resolucion_Problemas]] |
