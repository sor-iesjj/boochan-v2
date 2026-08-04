## Fase 1 · Apartado 7 — 🚩 Resolución de problemas

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Infraestructura Cloud (Azure IaaS)**
> 🧭 Índice de la fase: [[Fase_1]]
>
> **📍 Cuándo se lee:** **Cuando algo no salga.** Búscate por el síntoma.

---

> [!bug] Tabla de Troubleshooting (¿Algo no funciona?)
> | Problema | Causa Probable | Solución Sugerida |
> | :--- | :--- | :--- |
> | No puedo conectar por SSH ("Connection refused"). | La VM no ha terminado de arrancar. | Espera 2-3 minutos y vuelve a intentarlo. |
> | SSH se conecta pero pide contraseña en bucle. | La contraseña es incorrecta. | Comprueba que no tienes el Bloq Mayús activado. |
> | El servidor **no responde al ping**. | El protocolo ICMP está bloqueado por defecto en Azure. | Es normal por seguridad. No abras el ping; usa `telnet` o `nc` para probar puertos TCP. |

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_1.6_Procedimiento]] | [[Fase_1]] | [[Fase_1.8_Punto_de_Control]] |
