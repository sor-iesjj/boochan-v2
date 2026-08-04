## Fase 8 · Apartado 5 — 📚 Fundamento teórico

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Integración del Cliente (Windows 11)**
> 🧭 Índice de la fase: [[Fase_8]]
>
> **📍 Cuándo se lee:** **Antes de teclear.** Los conceptos que necesitas.

---

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

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_8.4_Donde_Estamos]] | [[Fase_8]] | [[Fase_8.6_Procedimiento]] |
