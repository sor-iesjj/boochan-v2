## Fase 1 · Apartado 5 — 📚 Fundamento teórico

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Infraestructura Cloud (Azure IaaS)**
> 🧭 Índice de la fase: [[Fase_1]]
>
> **📍 Cuándo se lee:** **Antes de teclear.** Los conceptos que necesitas.

---

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

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_1.4_Donde_Estamos]] | [[Fase_1]] | [[Fase_1.6_Procedimiento]] |
