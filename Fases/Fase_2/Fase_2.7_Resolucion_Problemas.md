## Fase 2 · Apartado 7 — 🚩 Resolución de problemas

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Purga y Preparación del Entorno**
> 🧭 Índice de la fase: [[Fase_2]]
>
> **📍 Cuándo se lee:** **Cuando algo no salga.** Búscate por el síntoma.

---

> [!bug] Troubleshooting (¿Algo no va bien?)
> | Problema | Causa Probable | Solución Sugerida |
> | :--- | :--- | :--- |
> | `apt purge` no encuentra Samba. | Samba no estaba instalado o ya lo borraste. | No te preocupes, verifica con `dpkg -l \| grep samba`. Si está vacío, perfecto. |
> | El nombre del servidor es incorrecto. | Error de escritura en `/etc/hostname` o `/etc/hosts`. | Ejecuta `hostname -f`. Debe devolver `UbuntuServer.BOOCHAN.SPACE`. |
> | La pantalla azul de Kerberos no aparece. | Ya está configurado de una instalación anterior. | Ejecuta `sudo dpkg-reconfigure krb5-config` para reconfigurarlo. |

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_2.6_Procedimiento]] | [[Fase_2]] | [[Fase_2.8_Punto_de_Control]] |
