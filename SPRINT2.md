# Sprint 2 · Navegación

En una WebApp drilldown, al navegar de una vista a otra (`WebRegisterPath ntNavigateForward` + `NavigatePath`)
DataFlex compara el DD del **InvokingObject** con el Main_DD de la **InvokedView** y decide el tipo de navegación:

| Tipo | Cuándo | Qué hace el framework |
|---|---|---|
| `nfFromMain` | misma tabla | la Select sirve para **elegir otro registro** de esa tabla |
| `nfFromChild` | la vista invocada es de una tabla **padre** | la Select sirve para **elegir el padre** del registro |
| `nfFromParent` | la vista invocada es de una tabla **hija** | la vista sale **filtrada** por el padre (`Constrain_File` dinámico) |
| `nfUndefined` | no hay relación entre los DD | ni filtra ni devuelve nada; sólo viaja lo que mandemos en `NamedValues` |

Orden de los eventos: `OnGetNavigateForwardData` (InvokingObject) → `OnNavigateForward` (InvokedView) →
… el usuario elige … → `OnGetNavigateBackData` (InvokedObject) → `OnNavigateBack` (InvokingObject).
Las vistas se apilan en el **ViewStack** (pila LIFO) y el **Breadcrumb** la muestra.

## 1. From main → Zoom jugador · Select jugador

`ZoomJugador.wo`: el campo **Apellido** tiene botón de búsqueda que abre `oSelectJugador`.

**¿Qué pasa con el InvokingObject?** El InvokingObject es el propio form `oJugadorApellido`. Como su DD
(Jugador) es el mismo que el de la Select, la navegación es `nfFromMain`. Al pulsar una fila, la Select hace
`NavigateClose`; el framework vuelve a buscar ese jugador en el DD principal del Zoom, de modo que **el Zoom pasa a
mostrar el jugador elegido** (no se rellena sólo el campo: cambia el registro entero). Después recibe el evento
`OnNavigateBack`, que usamos para actualizar el breadcrumb con el apellido nuevo.

## 2. From child → Zoom hijo · Select padre

Ya estaba hecho en el Sprint 1: en `ZoomJugador` y `ZoomEntrenador` el campo **Equipo**, y en `ZoomEquipo` el campo
**Liga**, abren la Select del padre. Es `nfFromChild`: al elegir una fila, el padre se asigna al registro hijo
(cambia `EquipoID` / `LigaID`) sin cambiar de jugador, entrenador o equipo.

## 3. From parent → Zoom liga

1. **Botón** (rama `feature/zoom-liga-boton-equipos`): "Ver equipos de esta liga" abre `oSelectEquipo`. Equipo es
   hija de Liga, así que es `nfFromParent` y el framework pone `Constrain_File` en el DD de Equipo: la lista sólo
   enseña los equipos de esa liga. En `OnNavigateForward` de la Select se muestra "Equipos de &lt;liga&gt;".
2. **Lista dentro del Zoom** (rama `feature/zoom-liga-lista-equipos`, sustituye al botón): el Zoom liga tiene un DD de
   Equipo con `DDO_Server` = DD de Liga y `Constrain_File` = Liga, y una `cWebList` con ese DD. Los equipos se ven sin
   navegar; al pulsar uno se abre su Zoom.

## 4. Undefined → Zoom jugador · Select posición

`ZoomJugador.wo`: botón **Ver posiciones** que abre `oSelectPosicion`.

**¿Hay relación entre ellas?** En la base de datos sí, pero **indirecta**: jugador y posición son N:M a través de
`jugadorposicion`. Entre los DD de las dos vistas no hay relación directa, así que la navegación es `nfUndefined`:
la Select muestra **todas** las posiciones, sin filtrar, y elegir una no devuelve nada al jugador. Para que llegue
algo hay que mandarlo a mano: el botón añade el nombre del jugador en `NamedValues` y la Select lo enseña en la
cabecera ("Posiciones (abierto desde …)").

## Otros cambios

- `fix/tildes-etiquetas`: corregidas tildes mal codificadas en etiquetas y mensajes ("País", "Máximo"…).
