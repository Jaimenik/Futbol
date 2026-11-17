# Data Dictionaries del proyecto

Un **Data Dictionary (DD)** es la clase que define las reglas de negocio de una tabla: qué campos son obligatorios,
cómo se relaciona con otras tablas, qué valores admite, qué pasa al guardar o borrar… Las vistas no repiten esas
reglas: se las piden al DD a través de los DDO (objetos DD que cada vista crea). Así, una regla escrita una vez se
cumple en todas las vistas.

Los DD están en `DDSrc`. Todos heredan de **`cFutbolDataDictionary`** (`DDSrc/cFutbolDataDictionary.pkg`), una clase
base propia que hereda de `DataDictionary` y añade lo que comparten (la validación de nombres).

## 1. Estructura y relaciones

| Propiedad | Para qué sirve | Dónde se usa |
|---|---|---|
| `Main_File` | tabla que gestiona el DD | todos |
| `Add_Server_File` | tabla **padre** (el hijo guarda su ID) | Equipo→Liga, Jugador→Equipo, Entrenador→Equipo |
| `Add_Client_File` | tabla **hija** | Liga→Equipo, Equipo→Jugador/Entrenador |
| `Cascade_Delete_State False` | no borrar en cascada: si hay hijos, el borrado se bloquea | todos |
| `ParentNullAllowed` | permite que el campo que apunta al padre quede a NULL | Jugador y Entrenador pueden no tener equipo |
| `piPrimaryIndex` | índice de la clave primaria (`ID`) | todos |

En las vistas, los DDO se encadenan igual que las tablas (`Set DDO_Server to oLiga_DD`). En `ZoomLiga` además el DD
de Equipo tiene `Constrain_File` = Liga, para que su lista sólo muestre los equipos de la liga actual.

## 2. Opciones de campo

| Opción | Qué hace | Ejemplo |
|---|---|---|
| `Field_Label_Long/Short` | etiqueta del campo en formularios y listas | "Nº de equipos" |
| `DD_REQUIRED` | no deja guardar el campo vacío | nombres, apellidos, país |
| `DD_NOPUT` + `DD_AUTOFIND` + `Key_Field_State` | el `ID` no se escribe a mano (AUTO_INCREMENT en MySQL) y sirve de clave | todos los `ID` |
| `DD_DISPLAYONLY` | se ve pero no se edita | `Liga.Equipos` (lo calcula el DD) |
| `Field_Value_Range` | rango permitido | `Liga.EquiposMax` entre 1 y 99 |
| `Status_Help` | texto de ayuda del campo | `ID`, `Nacionalidad`, `Equipos` |
| `Foreign_Field_Option` | comportamiento de los campos de otras tablas en una vista (sólo lectura, búsqueda obligatoria en la clave) | todos |

## 3. Tablas de validación (desplegables)

`DDSrc/FutbolValidationTables.pkg` define dos `ValidationTable`: **nacionalidades** y **países**. Con
`Field_Value_Table` el DD sólo acepta valores de la lista y, con `Field_Class_Name "Combo"`, Studio y la web los
pintan como desplegable. En las vistas basta con usar un `cWebCombo`: se rellena solo desde el DD.

- `Jugador.Nacionalidad` y `Entrenador.Nacionalidad` → `oNacionalidad_VT` (admite vacío: `Allow_Blank_State`).
- `Liga.Pais` → `oPais_VT`.

## 4. Validación de campos

`Field_Validate_msg` asocia a un campo una función que se ejecuta al salir de él y al guardar. La función
`ValidaNombre` (en la clase base) rechaza números y símbolos en **Nombre** y **Apellido** de jugadores y
entrenadores, mostrando el error con `Data_Set_Error`.

## 5. Eventos del DD

| Evento | Cuándo se dispara | Qué hacemos |
|---|---|---|
| `Field_Defaults` | al empezar un registro nuevo | `Liga.EquiposMax` = 20; `Nacionalidad` = "Español" |
| `Update` / `Backout` | al guardar / deshacer un equipo | suma o resta 1 a `Liga.Equipos` (el contador se mantiene solo, también al cambiar un equipo de liga) |
| `Validate_Save` | antes de guardar | Equipo: la liga no puede pasar de `EquiposMax`; Liga: el máximo no puede ser menor que los equipos actuales |
| `Validate_Delete` | antes de borrar | Liga: no se borra si tiene equipos; Equipo: no se borra si tiene jugadores o entrenador. Mensajes en español antes de que el DD lo bloquee por tener hijos |

Si una de estas funciones devuelve un valor distinto de 0, la operación se cancela y el usuario ve el mensaje de
`UserError`.

## 6. Cómo comprobarlo en la web

1. **Jugadores → uno → Editar**: la nacionalidad es un desplegable. Escribe un número en el apellido y guarda: sale
   el error de `ValidaNombre`.
2. **Jugadores → Nuevo**: la nacionalidad aparece ya como "Español" (`Field_Defaults`).
3. **Ligas → LaLiga → Eliminar**: "No se puede borrar LaLiga: todavía tiene 3 equipos".
4. **Equipos → Real Madrid → Eliminar**: "No se puede borrar Real Madrid: todavía tiene jugadores".
5. **Ligas → una → Editar**: pon el máximo de equipos por debajo de los que tiene y guarda: salta `Validate_Save`.
