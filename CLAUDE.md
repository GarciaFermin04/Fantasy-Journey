# CLAUDE.md

Roguelite RPG por turnos (nombre de trabajo: "Torre Cambiante"). Godot 4.7, GDScript. Desarrollo solo, con Claude Code como programador.
Estas reglas son obligatorias. Si una tarea choca con alguna, avisá antes de hacerla.

## Documentos de referencia

- `docs/diseno.md`: diseño del juego. Leerlo antes de implementar cualquier sistema de juego.
- `docs/plan.md`: plan de desarrollo. Al terminar una tarea, marcarla como `[x]` en el mismo commit.
- `docs/decisiones/`: una nota corta por cada decisión técnica o de diseño relevante (qué se eligió y por qué).

---

## 1. Forma de trabajar

1. **Primero planificar, después programar.** Antes de escribir código para una tarea, presentar un plan corto:
   - archivos a crear o modificar (con su ruta),
   - escenas y nodos principales,
   - clases, Resources y componentes nuevos, y por qué hacen falta,
   - cómo se conecta con lo que ya existe.

   Esperar mi OK si la tarea crea un sistema nuevo o cambia la arquitectura. En cambios chicos se puede seguir directo.
2. **Reutilizar antes de crear.** Revisar qué existe en `scripts/`, `scenes/`, `data/` y `addons/` antes de crear algo nuevo. No duplicar lógica.
3. **Una tarea a la vez.** No adelantar tareas del plan ni agregar features que no pedí.
4. **Si hay dudas de diseño, preguntar.** No inventar reglas de juego. Si algo no está en `docs/diseno.md`, consultarme.
5. **Al terminar cada tarea:** correr los tests, hacer commit, actualizar `docs/plan.md` y explicarme en 3-4 líneas qué se hizo y qué nodos o patrones se usaron (estoy aprendiendo 3D en Godot).

## 2. Estructura

- Respetar la estructura de carpetas existente. Si algo no encaja, proponer dónde va **antes** de crear carpetas nuevas.
- Los scripts adjuntos a una escena viven al lado de su `.tscn`, con el mismo nombre. En `scripts/` solo va lógica pura y reutilizable, sin escena asociada.
- Los componentes reutilizables (escena + script) van en `scenes/components/`.
- Datos del juego como Resources (`.tres`) en `data/`, nunca hardcodeados. Sus clases se definen en `scripts/resources/`.
- No editar la carpeta `.godot/`.
- `demo/` es el demo de LimboAI, no es código del juego. No modificarlo ni usarlo como base.

## 3. Arquitectura

### Separación de responsabilidades
- **Lógica ≠ presentación.** Las reglas del juego (daño, turnos, afinidades, economía, generación de pisos, desbloqueos) viven en clases de lógica pura (`RefCounted` o `Resource`) dentro de `scripts/`, sin depender de nodos ni escenas. Las escenas solo muestran y reciben input.
- Toda la lógica de combate (daño, afinidad, debilidades, turnos) va en `scripts/combat/`, con tests en `tests/unit/combat/`.
- **Datos ≠ código.** Stats, números de balance y textos del juego van en Resources, no en el código.

### Composición antes que herencia
- Preferir **componentes con una sola responsabilidad** (nodos hijos reutilizables) antes que jerarquías profundas. Ejemplos: `HealthComponent`, `StatsComponent`, `InteractableComponent`, `FollowComponent`.
- Herencia máximo 2 niveles (por ejemplo `BaseRoom → CombatRoom`). Si hace falta más, usar composición.

### Comunicación entre nodos
- **"Llamar hacia abajo, señales hacia arriba":** un padre puede llamar métodos de sus hijos; un hijo nunca llama al padre, emite una **señal**.
- Entre sistemas no relacionados, usar el autoload `event_bus` con señales tipadas. Si dos nodos están en la misma escena, conectarlos directo.
- Prohibido: `get_parent().get_parent()`, rutas largas tipo `get_node("../../X")` y buscar nodos por nombre en todo el árbol. Usar `@export` para referencias o nombres únicos de escena (`%Nodo`).

### Autoloads
- Solo para estado o servicios globales (por ejemplo `game_state`, `run_state`, `event_bus`, `save_manager`, `scene_manager`, `audio_manager`).
- No crear autoloads nuevos sin preguntar. Nunca poner lógica de gameplay dentro de un autoload.

### Máquinas de estado e IA
- Todo lo que tenga fases (combate, turnos, IA enemiga, flujo de la run, menús complejos) se implementa como **máquina de estados explícita**, con transiciones claras. Nada de cadenas de `if` con booleanos.
- Para el flujo de combate, proponer en el plan si se usa `LimboHSM` o una máquina de estados propia en `scripts/combat/`, y justificarlo (la lógica de reglas tiene que seguir siendo testeable sin escenas).

### Escenas
- Cada escena es **autocontenida**: se puede ejecutar sola con F6 para probarla (con datos de prueba si hace falta).
- Si algo se repite en 2 o más escenas, se extrae a una escena o componente reutilizable.

## 4. Addons instalados

**Regla general:** si un addon instalado resuelve lo que pide la tarea o facilita el trabajo, **usarlo en lugar de programarlo desde cero**. En el plan de cada tarea, indicar qué addon se va a usar y para qué (o por qué no se usa).

| Addon | Para qué usarlo |
|---|---|
| **LimboAI** | IA enemiga con Behavior Trees; estados de agentes con `LimboHSM` (exploración, combate, animaciones). |
| **Dialogue Manager** | Todos los diálogos: NPCs del Reino, eventos de la Torre, reclutas, diálogos de Vínculo. Los diálogos se escriben en archivos `.dialogue` (guardarlos en `data/dialogue/`), nunca hardcodeados en scripts. |
| **Phantom Camera** | Todas las cámaras: cámara de exploración que sigue al líder, enfoque de la sala al entrar en combate, cambios de cámara en eventos y cinemáticas. Usar transiciones entre `PhantomCamera3D` con prioridades en vez de mover la cámara a mano. |
| **GUT** | Tests unitarios y de integración (ver sección 6). |

- Antes de usar un addon por primera vez en una tarea, revisar su documentación y ejemplos dentro de `addons/<addon>/` para usar la API de la versión instalada, sin suponer.
- **No modificar el código de los addons.** Si hace falta cambiar su comportamiento, extenderlo o envolverlo desde `scripts/`.
- Los demos o ejemplos que traen los addons no son código del juego.
- Si se instala un addon nuevo, agregarlo a esta tabla con su uso.

## 5. Código

- GDScript con **tipado estático siempre** (variables, parámetros y retornos).
- **Nombres:** archivos y carpetas en `snake_case`; `class_name` en `PascalCase`; funciones y variables en `snake_case`; constantes y valores de enums en `UPPER_SNAKE_CASE`; señales en pasado (`died`, `turn_started`); miembros privados con `_` adelante.
- **Código en inglés; textos visibles del juego en español.**
- **Orden dentro del script** (guía oficial de GDScript): `class_name` → `extends` → doc `##` → señales → enums → constantes → `@export` → variables públicas → variables privadas → `@onready` → `_init` → `_ready` → otros callbacks de Godot → métodos públicos → métodos privados.
- **Sin números mágicos:** usar constantes, `@export` o Resources.
- **Documentación:** comentario `##` en cada clase y en cada método público explicando qué hace.
- **Tamaño:** una clase por archivo. Si un script pasa las ~300 líneas o una función las ~40, dividir.
- **Errores:** `assert()` para validar en desarrollo; `push_error()` / `push_warning()` en casos recuperables. Nunca fallar en silencio.
- **Rendimiento básico:** nada pesado en `_process` / `_physics_process`; preferir señales y timers. Cachear nodos con `@onready`.
- Nada de código comentado ni `TODO` sueltos. Lo pendiente se anota en `docs/plan.md`.

## 6. Tests

Correr los tests después de cambios en lógica:

```
godot --headless -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit
```

`godot` no está en el PATH; el ejecutable está en
`C:\Steam\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe`.

- Los tests usan GUT (`addons/gut`), extienden `GutTest` y sus archivos empiezan con `test_`.
- Ubicación: `tests/unit/<sistema>/` y `tests/integration/`.
- Toda lógica pura de reglas lleva tests. Al agregar o cambiar lógica, agregar o actualizar sus tests en el mismo commit.
- No hacer commit si los tests fallan.

## 7. Git

- Cambios chicos, un commit por tarea o cambio lógico.
- Mensajes en español con prefijo: `feat:`, `fix:`, `refactor:`, `test:`, `docs:`, `chore:`. Referenciar el ID de la tarea del plan. Ejemplo: `feat: cola de turnos por velocidad (3.2)`.

## 8. Prohibido sin preguntar

- Instalar plugins o addons.
- Cambiar Project Settings, el Input Map o los autoloads (salvo que la tarea lo pida explícitamente).
- Borrar o renombrar archivos o carpetas existentes.
- Refactorizar código no relacionado con la tarea actual (proponerlo aparte).

## 9. Definición de "terminado"

Una tarea está terminada cuando:
- cumple lo pedido en `docs/plan.md`,
- respeta estas reglas,
- los tests pasan (y hay tests nuevos si hubo lógica nueva),
- la escena se puede probar sola,
- el commit está hecho y `docs/plan.md` está actualizado.
