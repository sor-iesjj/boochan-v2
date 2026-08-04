## Fase 4 · Apartado 10 — 🏁 Auditoría y cierre

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Aprovisionamiento del Dominio (Samba AD DC)**
> 🧭 Índice de la fase: [[Fase_4]]
>
> **📍 Cuándo se lee:** **Lo último.** No pases a la fase siguiente sin repasarlo.

---

> [!caution] 🛑 Auditoría y Evaluación (RA.03)
> **Peligro Crítico:** Si el DNS vuelve a apuntar a Azure en lugar de a 127.0.0.1, los ordenadores dirán "No se encuentra el dominio" y nadie podrá iniciar sesión.

> [!success] 🏁 Punto de Control (Antes de seguir)
> Antes de ejecutar las verificaciones, instala las herramientas de diagnóstico DNS (no vienen preinstaladas en Ubuntu Server):
> ```bash
> sudo apt install dnsutils -y
> ```
> - [ ] ¿Responde `samba-tool domain level show` sin errores?
> - [ ] ¿El comando `nslookup _kerberos._tcp.BOOCHAN.SPACE` devuelve la IP correcta?

---

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_4.9_Preguntas]] | [[Fase_4]] | **Fase 5** |
