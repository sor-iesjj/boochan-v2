## Fase 3 · Apartado 9 — ❓ Preguntas críticas

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Conectividad VPN (WireGuard)**
> 🧭 Índice de la fase: [[Fase_3]]
>
> **📍 Cuándo se lee:** **Después de la instantánea.** Trabajo de mesa, en tu entrada.

---

> [!help] Preguntas Críticas (Autoevaluación)
> 1. ¿Por qué la llave privada **NUNCA** debe salir de tu servidor ni enviarse por correo?
> 2. ¿Qué ventaja tiene WireGuard sobre protocolos antiguos en términos de rendimiento?
> 3. ¿Para qué sirve el parámetro `AllowedIPs` en la configuración del Peer?
> 4. 🔬 **Reto práctico:** Con el túnel activo, ejecuta `sudo wg show` en el servidor y localiza la línea `latest handshake`. ¿Hace cuántos segundos fue el último intercambio? Ahora desactiva el túnel desde tu PC del aula y vuelve a ejecutar el comando 30 segundos después. ¿Qué cambió en esa línea? ¿Qué te dice eso sobre el estado de la conexión?
> 5. 🔬 **Reto práctico:** Con el túnel WireGuard **desactivado** en tu PC, intenta conectarte al servidor por SSH usando la IP pública de Azure (no la `10.0.0.1`). ¿Puedes entrar? ¿Por qué sí o por qué no? Razona tu respuesta mirando las reglas del NSG que configuraste en esta fase.

---

> [!danger] ⚠️ Las respuestas van en la ENTRADA, no en un documento aparte
> Estas preguntas demuestran que has **entendido** lo que has hecho, y no solo que has sabido copiar comandos. Se contestan **con tus palabras**. Una fase con el procedimiento perfecto y las preguntas en blanco está **incompleta**.

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_3.8_Punto_de_Control]] | [[Fase_3]] | [[Fase_3.10_Auditoria_y_Cierre]] |
