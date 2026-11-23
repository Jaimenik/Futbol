# Sprint 4 · Data Dictionary (1)

## 1. Construcción de la clase

### Proteger las PK — `Key_Field_State`
El `ID` de todas las tablas (`liga`, `posicion`, `equipo`, `entrenador`, `jugador`, `jugadorposicion`) tiene
`Key_Field_State True`. Con `Protect_Key_State` (True por defecto en el DD) DataFlex no deja cambiar la clave de un
registro que ya existe. Además el `ID` es `DD_NOPUT` + `DD_AUTOFIND`: lo asigna MySQL (AUTO_INCREMENT) y escribirlo
sirve para buscar.

### Nombres que no se pueden modificar
Campos: `Nombre` de todas las tablas y `Apellido` de jugador y entrenador.

| Opción | Qué hace | Problema |
|---|---|---|
| `DD_NOPUT` | se puede escribir, pero el valor **no se guarda** | en un registro nuevo el nombre tampoco se guarda → no se pueden crear registros (es obligatorio) |
| `DD_NOENTER` | el campo no recibe el foco: no se puede escribir | igual: no hay forma de poner el nombre de un registro nuevo |
| `DD_DISPLAYONLY` | NOPUT + NOENTER: sólo se ve | el mismo problema |

Las tres protegen **siempre**, también al crear. Por eso elegimos **`DD_COMMIT`**, la opción del DD pensada para
esto: mientras el registro es nuevo el campo se escribe con normalidad y, en cuanto está guardado ("committed"),
DataFlex lo trata como `DD_DISPLAYONLY` (o `DD_NOPUT` si el campo tiene índice). Resultado: el nombre se pone al
crear y luego no se puede cambiar.

```dataflex
Set Field_Option Field Jugador.Nombre DD_REQUIRED to True
Set Field_Option Field Jugador.Nombre DD_COMMIT to True
```

### Requeridos los campos NOT NULL de la BD

| Tabla | NOT NULL | Cómo se exige |
|---|---|---|
| liga | Nombre, Pais, EquiposMax | `DD_REQUIRED` (Equipos tiene DEFAULT 0 y lo calcula el DD) |
| posicion | Nombre | `DD_REQUIRED` |
| equipo | Nombre | `DD_REQUIRED` |
| equipo | LigaID | `Validate_Save`: "Elige la liga del equipo" |
| entrenador, jugador | Nombre, Apellido | `DD_REQUIRED` |
| jugadorposicion | JugadorID, PosicionID | `Validate_Save`: "Elige el jugador y la posición" |

Las claves ajenas (LigaID, JugadorID, PosicionID) no se ponen con `DD_REQUIRED` porque el usuario no las escribe: el
DD las copia del registro padre al guardar (después de validar los campos). Por eso se comprueba en `Validate_Save`
que el padre exista.

## 2. Null — botón "Despedir"

`ZoomEntrenador.wo` tiene la acción **Despedir** (sólo aparece si el entrenador tiene equipo). Pide confirmación
(`ShowYesNo`) y, si se acepta:

```dataflex
Send Clear of oEquipo_DD                 // el DDO padre se queda sin registro
Set Changed_State of oEntrenador_DD to True
Send Request_Save                        // EquipoID se guarda como NULL
```

Funciona porque el DD de Entrenador tiene `Set ParentNullAllowed Equipo.File_Number to True`: sin esa propiedad, al
guardar sin padre DataFlex escribiría 0 en `EquipoID` y MySQL lo rechazaría por la clave ajena.

## 3. Validación — nacionalidad con CodeMast/CodeType

`Jugador.Nacionalidad` y `Entrenador.Nacionalidad` son un **desplegable** (`cWebCombo`) en lugar de un `cWebForm`:
el usuario elige, no escribe.

- La lista está en las **tablas de códigos** de DataFlex (convertidas a MySQL en el Sprint 1):
  - `CodeType`: tipo `NACION` ("Nacionalidades") y tipo `PAIS` ("Países").
  - `CodeMast`: un registro por valor. Para `NACION`, **sólo las 19 nacionalidades que tienen hoy jugadores y
    entrenadores**.
- En el DD: `oNacionalidad_VT is a CodeValidationTable` con `Type_Value "NACION"`, asignada con
  `Field_Value_Table` (`DDSrc/FutbolValidationTables.pkg`). El combo se rellena solo desde el DD.
- La carga se hace con el programa `AppSrc/CargarCodigos.src`, que no duplica si se ejecuta otra vez.

Hubo que ampliar `codemast.Code` de 10 a 30 caracteres ("Mozambiqueño" y "Países Bajos" no cabían). Lo hace el propio
`CargarCodigos` con SQL embebido (`ALTER TABLE codemast MODIFY Code VARCHAR(30) NOT NULL`). Ojo: DataFlex guarda la
estructura de cada tabla en `Data\<tabla>.x64.cch`; tras cambiarla en MySQL hay que borrar ese archivo para que la
vuelva a leer.

## Cómo comprobarlo

1. **Jugadores → Nuevo**: se puede escribir nombre y apellido; la nacionalidad es un desplegable con las 19 de la lista.
2. Guarda y vuelve a abrirlo → **Editar**: nombre y apellido ya no se pueden cambiar.
3. **Equipos → Nuevo** sin elegir liga → "Elige la liga del equipo".
4. **Entrenadores → Ancelotti → Despedir → Sí**: en la lista aparece sin equipo y, en MySQL, `EquipoID` es `NULL`.
   Para devolverlo: Editar → lupa de Equipo → Real Madrid → Guardar.
