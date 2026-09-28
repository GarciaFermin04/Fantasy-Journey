# 009 - Máquina de estados del combate: propia en vez de LimboHSM

**Fecha:** 2026-09-28 · **Tarea:** 3.1

## Decisión
El flujo del combate es una máquina de estados propia, `CombatStateMachine` (`scripts/combat/combat_state_machine.gd`), una clase `RefCounted` sin nodos:

```
IDLE → STARTING → AWAITING_ACTION → RESOLVING_ACTION → TURN_ENDED ─┬→ AWAITING_ACTION (siguiente turno)
                                                                   └→ FINISHED (VICTORY / DEFEAT)
```

- Transiciones en una tabla explícita (`Dictionary[State, Array]`), sin cadenas de `if` con booleanos.
- Cada método (`start`, `begin_turn`, `submit_action`, `action_resolved`, `end_combat`) devuelve `bool`; una transición inválida no cambia el estado y hace `push_error`.
- Señales para la futura escena de combate: `state_changed`, `turn_started`, `action_submitted`, `combat_finished`.
- La máquina solo garantiza el orden de los pasos. Quién actúa (cola de turnos, 3.2), qué hace la acción (3.5) y quién gana (3.6) lo deciden otros sistemas.

## Por qué no LimboHSM
- En LimboHSM los estados son nodos (`LimboState` extiende `Node`) dentro del árbol de escena. Testearlo exige instanciar nodos; CLAUDE.md pide que la lógica de reglas sea testeable sin escenas.
- LimboHSM brilla con agentes que se actualizan cada frame. El combate por turnos es una secuencia discreta de eventos.
- LimboAI sigue siendo la opción para estados de agentes en exploración/animaciones y, si hace falta, para la IA (se decide en 3.7).

## Notas
- `actor` y `action` son `Object`/`Variant` provisorios hasta que existan sus clases (3.2-3.6).
- GUT 9.7 falla un test ante `push_error` no esperado; los tests de transiciones inválidas usan `assert_push_error`.
