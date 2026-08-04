## Fase 3 · Apartado 7 — 🚩 Resolución de problemas

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Conectividad VPN (WireGuard)**
> 🧭 Índice de la fase: [[Fase_3]]
>
> **📍 Cuándo se lee:** **Cuando algo no salga.** Búscate por el síntoma.

---

> [!bug] Troubleshooting (¿No hay conexión?)
> | Problema | Causa Probable | Solución Sugerida |
> | :--- | :--- | :--- |
> | `Address already in use`. | Ya hay otra interfaz VPN activa con esa IP. | Ejecuta `sudo wg-quick down wg0` antes de volver a levantarla. |
> | No hay ping entre 10.0.0.1 y 10.0.0.2. | El puerto 51820 UDP está cerrado en Azure. | Abre el puerto 51820 **UDP** (no TCP) en el NSG de Azure. |
> | WireGuard no conecta pero el puerto está abierto. | Las llaves públicas están intercambiadas incorrectamente. | Verifica que la llave pública del cliente en el servidor y la del servidor en el cliente son exactas. |

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_3.6_Procedimiento]] | [[Fase_3]] | [[Fase_3.8_Punto_de_Control]] |
