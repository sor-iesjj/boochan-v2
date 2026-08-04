## Fase 4 · Apartado 7 — 🚩 Resolución de problemas

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Aprovisionamiento del Dominio (Samba AD DC)**
> 🧭 Índice de la fase: [[Fase_4]]
>
> **📍 Cuándo se lee:** **Cuando algo no salga.** Búscate por el síntoma.

---

> [!bug] Troubleshooting (¿El dominio no nace?)
> | Problema | Causa Probable | Solución Sugerida |
> | :--- | :--- | :--- |
> | Error `Realm not found`. | El archivo `/etc/krb5.conf` no está bien configurado. | Copia el generado por Samba: `sudo cp /var/lib/samba/private/krb5.conf /etc/krb5.conf`. |
> | No resuelve al 127.0.0.1. | `systemd-resolved` está secuestrando el DNS por un error del script. | Apágalo con `sudo systemctl disable systemd-resolved --now`, luego destruye el enlace `sudo rm /etc/resolv.conf` e inyecta la IP: `echo "nameserver 127.0.0.1" | sudo tee /etc/resolv.conf`. Por último, bloquéalo de nuevo con `sudo chattr +i /etc/resolv.conf`. |

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_4.6_Procedimiento]] | [[Fase_4]] | [[Fase_4.8_Punto_de_Control]] |
