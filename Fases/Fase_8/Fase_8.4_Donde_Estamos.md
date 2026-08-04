## Fase 8 · Apartado 4 — 🎯 ¿Dónde estamos?

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Integración del Cliente (Windows 11)**
> 🧭 Índice de la fase: [[Fase_8]]
>
> **📍 Cuándo se lee:** **Antes de empezar.** De dónde vienes y a dónde llegas.

---

> [!info] Vienes de Fase 7
> El servidor Linux es ahora un "reino" completo: dominio, usuarios, grupos, discos protegidos, y permisos granulares. Todo está funcionando perfectamente desde la terminal. Sin embargo, los usuarios del aula están esperando en sus PCs Windows 11 — ahora necesitas que esos equipos confíen en el servidor y usen sus identidades de dominio.

> [!warning] El Problema
> Windows y Linux hablan idiomas diferentes de seguridad. Windows necesita: (1) encontrar el servidor por DNS, (2) sincronizar el reloj exactamente (Kerberos rechaza diferencias > 5 minutos), (3) establecer una "relación de confianza" registrándose en Active Directory, (4) permitir que los usuarios inicien sesión con sus credenciales de dominio. Si algo falla, el usuario ve "No se encuentra el dominio" o "Error de relación de confianza".

> [!success] Objetivo de esta Fase
> **Unir Windows 11 al dominio BOOCHAN.SPACE** de forma que los usuarios puedan iniciar sesión con sus credenciales de dominio (ej. `BOOCHAN\user1`) y acceder a las carpetas compartidas del servidor con los permisos que se les asignaron en Linux. Es el momento de la verdad: la infraestructura híbrida (Linux servidor + Windows cliente) funcionando en sinergia.

> [!tip] Hoja de Ruta
> 1. **Validar VPN:** Activar el túnel WireGuard en el PC del aula para acceder a la red privada 10.0.0.0/24
> 2. **Configurar DNS de Windows:** Cambiar DNS primario a 10.0.0.1 (el servidor), DNS secundario a 8.8.8.8 (fallback a internet)
> 3. **Sincronizar reloj:** Ejecutar `w32tm /resync /force` para emparejar la hora exactamente con el servidor
> 4. **Unir al dominio:** A través de Configuración → Sistema → Acerca de, introducir `BOOCHAN.SPACE` y credenciales de Administrator
> 5. **Reiniciar Windows:** Obligatorio para aplicar los cambios de dominio
> 6. **Primer login:** Iniciar sesión con `BOOCHAN\user1` y su contraseña desde la pantalla de inicio
> 7. **Instalar RSAT:** Herramientas administrativas para gestionar usuarios/grupos desde Windows gráficamente
> 8. **Mapear carpetas de red:** Conectar `\\UbuntuServer.BOOCHAN.SPACE\prueba1` y `prueba3` como unidades de red (Z:, por ejemplo)
>
> **Resultado Final:** Windows 11 es ahora un cliente legítimo del dominio. Los usuarios pueden iniciar sesión, acceder a carpetas según sus permisos de grupo, y crear archivos que el servidor Linux reconoce automáticamente.
> **Siguiente:** Fase completada — el proyecto es funcional de extremo a extremo. Servidor Linux como DC, usuarios en AD, almacenamiento seguro, y clientes Windows integrados.

---

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_8.3_Obligaciones_Grabacion]] | [[Fase_8]] | [[Fase_8.5_Fundamento_Teorico]] |
