## Fase 3 · Apartado 4 — 🎯 ¿Dónde estamos?

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Conectividad VPN (WireGuard)**
> 🧭 Índice de la fase: [[Fase_3]]
>
> **📍 Cuándo se lee:** **Antes de empezar.** De dónde vienes y a dónde llegas.

---

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

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_3.3_Obligaciones_Grabacion]] | [[Fase_3]] | [[Fase_3.5_Fundamento_Teorico]] |
