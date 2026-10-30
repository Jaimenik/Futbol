# FutbolWebApp (Sprint 1)

Aplicación web DataFlex 2026 (plantilla *Foundation – Drilldown*) sobre la base de datos MySQL `futbol`.

## Qué incluye

- Tablas de MySQL conectadas: `liga`, `posicion`, `equipo`, `entrenador`, `jugador` y `jugadorposicion`, con sus relaciones.
- Tablas embebidas de la plantilla convertidas a MySQL: `CodeMast`, `CodeType`, `WebAppSession`, `WebAppUser` y `WebAppServerProps`.
- Data Dictionaries de cada tabla (`DDSrc`).
- Vistas Select y Zoom de liga, posición, equipo, entrenador y jugador (`AppSrc`).
- Tarjetas de esas cinco tablas en `Dashboard.wo`.

## Puesta en marcha

1. Crear la BD ejecutando el script `futbol.sql` en MySQL 8.4.
2. Instalar MySQL Connector/ODBC 9.6 (64 bits).
3. Copiar `Data\DfConnId.ini.example` como `Data\DfConnId.ini` y guardar la contraseña de MySQL
   ejecutando `Programs\guardar_password.ps1` (la guarda cifrada con la clave del workspace).
4. Para entrar en la web con el usuario `admin`, ponerle una contraseña con `Programs\cambiar_password_admin.ps1`.
5. Abrir `DataControl.sws` en DataFlex Studio 2026 y ejecutar (F5).

## Flujo de trabajo (gitflow)

- `main`: producto final.
- `develop`: versión funcional donde se integran las features.
- `feature/*`: una rama por funcionalidad (conexión a la BD, cada vista y las tarjetas del Dashboard).
