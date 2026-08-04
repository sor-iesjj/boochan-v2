## Fase 1 · Apartado 10 — 🏁 Auditoría y cierre

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Infraestructura Cloud (Azure IaaS)**
> 🧭 Índice de la fase: [[Fase_1]]
>
> **📍 Cuándo se lee:** **Lo último.** No pases a la fase siguiente sin repasarlo.

---

> [!caution] 🛑 Auditoría de Seguridad — Tarea pendiente tras la Fase 3
> Una vez que la VPN esté funcionando, realizarás dos acciones para cerrar el servidor al mundo exterior. **No las hagas ahora**: sin VPN activa te quedarías sin acceso.
>
> **Acción 1 — Cambiar el puerto SSH de 22 a 2222 en el servidor:**
> ```bash
> sudo nano /etc/ssh/sshd_config
> ```
> Busca la línea `#Port 22`, elimina el `#` y cambia el número a `2222`. Guarda y reinicia el servicio:
> ```bash
> sudo systemctl restart ssh
> ```
> A partir de aquí, conéctate siempre con:
> ```bash
> ssh -p 2222 boochan@10.0.0.1
> ```
>
> **Acción 2 — Cerrar el puerto 22 en el NSG de Azure:**
> Vuelve a **Configuración de red** → NSG → **Reglas de seguridad de entrada**. Localiza la regla del puerto 22 que Azure creó por defecto y **elimínala**. El puerto 2222 ya está abierto desde el paso 2 de esta fase.
>
> Esto es aplicar seguridad "Zero Trust": nadie en Internet puede llegar al servidor; solo quien esté dentro de la VPN.

---

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_1.9_Preguntas]] | [[Fase_1]] | **Fase 2** |
