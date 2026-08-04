## Fase 5 · Apartado 5 — 📚 Fundamento teórico

> **[Módulo: SOR — Sistemas Operativos en Red]** · **Gestión de Identidades (Usuarios y Grupos)**
> 🧭 Índice de la fase: [[Fase_5]]
>
> **📍 Cuándo se lee:** **Antes de teclear.** Los conceptos que necesitas.

---

> [!abstract] 1. La "Traducción de Mundos"
> En esta fase ocurre la magia de la interoperabilidad. Windows identifica usuarios con un **SID** (una cadena alfanumérica muy larga e ilegible). Linux, por el contrario, usa un **UID** (un número corto de 4 o 5 cifras). 

> [!info] 2. El Estándar RFC 2307
> Para que un usuario de Windows pueda guardar un archivo en el disco duro de nuestro servidor Linux, necesitamos el estándar **RFC 2307**. Esto permite añadir atributos técnicos de Unix (como el número de usuario o la carpeta /home) directamente en la ficha del Active Directory. Es la única forma de que los permisos de archivo sean consistentes y no haya errores de "Acceso Denegado".

### 📖 Diccionario de Conceptos Clave

> [!quote] Terminología de Identidades
> - **UID-Number:** El identificador numérico único que el Kernel de Linux asigna a un usuario.
> - **GID-Number:** El identificador numérico para un grupo de usuarios.
> - **Mapeo:** La relación 1 a 1 entre un usuario de Windows y un ID de Linux.
> - **samba-tool:** La "Navaja Suiza" para gestionar todos los aspectos del dominio desde la terminal.

---

### 🔓 Apertura de Puertos (NSG de Azure)

> [!info] ℹ️ Sin cambios en el NSG en esta fase
> El puerto **445 (SMB)** que necesita esta fase ya fue abierto en la **Fase 4**, junto con el resto de puertos de Active Directory. No tienes que añadir ninguna regla nueva en Azure.
>
> Si al conectarte desde Windows la carpeta no aparece y sospechas que es un problema de puerto, verifica en el NSG que la regla `SMB_Files` (prioridad 418) existe y está habilitada.

---

---

| ← Anterior | 🧭 Índice | Siguiente → |
| :--- | :---: | ---: |
| [[Fase_5.4_Donde_Estamos]] | [[Fase_5]] | [[Fase_5.6_Procedimiento]] |
