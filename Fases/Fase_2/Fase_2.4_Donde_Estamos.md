## Fase 2 · Apartado 4 — 🎯 ¿Dónde estamos?

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Purga y Preparación del Entorno**
> 🧭 Índice de la fase: [[Fase_2]]
>
> **📍 Cuándo se lee:** **Antes de empezar.** De dónde vienes y a dónde llegas.

---

> [!info] Vienes de Fase 1
> Creaste un servidor Ubuntu en Azure. Está encendido, accesible por SSH, protegido por NSG. Pero viene "de fábrica" con software innecesario: servicios antiguos, demonios durmiendo, paquetes que consumirán RAM y podrían ser puertas de seguridad.

> [!warning] El Problema
> Ubuntu instala de serie Samba básico (para "compartir archivos entre amigos"). Este Samba primitivo ocupa el puerto 445, que tu futuro **Controlador de Dominio profesional** (Fase 4) necesitará. Además, servicios como CUPS (impresoras) o IMAP (correo) están dormidos pero activos, consumiendo recursos. El servidor tampoco sabe su identidad: `/etc/hosts` dice "localhost" sin un verdadero nombre de dominio.

> [!success] Objetivo de esta Fase
> **Purga:** Eliminar completamente Samba viejo, impresoras, CUPS, servicios heredados. **Identidad:** Configurar `/etc/hosts` para que el servidor sepa que se llama `UbuntuServer.BOOCHAN.SPACE`. Esto es imprescindible porque Kerberos (Fase 4) valida identidades por nombre de dominio completo (FQDN).

> [!tip] Hoja de Ruta
> 1. Ejecutar `apt update && apt upgrade -y` (actualizar repositorio y parches de seguridad)
> 2. Usar `apt purge` (no solo `remove`) para borrar Samba viejo, CUPS, servicios heredados
> 3. Ejecutar `apt autoremove` para limpiar dependencias orfandas
> 4. Editar `/etc/hosts` e insertar: `10.0.0.1  UbuntuServer.BOOCHAN.SPACE  UbuntuServer`
> 5. Verificar con `hostname -f` que devuelve exactamente `UbuntuServer.BOOCHAN.SPACE`
> 6. Validar resolución: `ping UbuntuServer` y `ping UbuntuServer.BOOCHAN.SPACE` responden
>
> **Resultado Final:** Servidor limpio, sin ruido de servicios heredados, con identidad de dominio establecida.
> **Siguiente:** Fase 3 (Conectividad VPN) — instalarás WireGuard para que el aula pueda acceder de forma segura y privada al servidor.

---

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_2.3_Obligaciones_Grabacion]] | [[Fase_2]] | [[Fase_2.5_Fundamento_Teorico]] |
