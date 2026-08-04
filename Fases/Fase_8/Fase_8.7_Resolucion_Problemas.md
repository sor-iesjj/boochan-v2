## Fase 8 · Apartado 7 — 🚩 Resolución de problemas

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Integración del Cliente (Windows 11)**
> 🧭 Índice de la fase: [[Fase_8]]
>
> **📍 Cuándo se lee:** **Cuando algo no salga.** Búscate por el síntoma.

---

> [!bug] Troubleshooting (¿No puedes unirte?)
> | Problema | Causa Probable | Solución Sugerida |
> | :--- | :--- | :--- |
> | "No se encuentra el dominio". | El cliente está usando el DNS del router, no el nuestro. | Comprueba que el DNS primario es `10.0.0.1` y que la VPN está activa. |
> | "Error de relación de confianza". | Desfase horario (Clock Skew) superior a 5 minutos. | Comprueba la zona horaria en ambos y ejecuta `w32tm /resync /force`. |
> | La unidad `Z:` no aparece al reiniciar. | El mapeo no es persistente. | Añade `/persistent:yes` al final del comando `net use`. Recuerda que la VPN debe estar activa antes de que Windows intente reconectar la unidad. |

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_8.6_Procedimiento]] | [[Fase_8]] | [[Fase_8.8_Punto_de_Control]] |
