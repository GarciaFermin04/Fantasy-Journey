# 010 - Cola de turnos por velocidad

**Fecha:** 2026-09-28 · **Tarea:** 3.2

## Reglas de diseño definidas
- **Rondas:** cada unidad viva actúa una vez por ronda (una unidad rápida no actúa dos veces, salvo habilidad u objeto que lo permita).
- **Orden dinámico:** antes de cada turno se reordena a los que faltan actuar según su velocidad actual. Si alguien que no actuó pierde velocidad, baja en la cola de inmediato. Si alguien que ya actuó gana velocidad, no vuelve a actuar hasta la ronda siguiente.
- **Empates:** aliados antes que enemigos; dentro del mismo bando, el orden de la formación.
- **Barra:** muestra quién actúa, los que faltan en la ronda y una vista previa atenuada de la próxima ronda.
- **Derrotados:** pierden su turno y desaparecen de la barra.

## Modelo
- `Combatant` (`scripts/combat/combatant.gd`): unidad en combate con el estado que cambia durante la pelea (stats actuales, derrota). Se crea desde `RecruitData` (con el bonus del arma) o `EnemyData`, sin modificar los `.tres`. La 3.6 le suma vida, maná y estamina.
- `TurnQueue` (`scripts/combat/turn_queue.gd`): `next_actor()` reordena a los pendientes, saca al primero y arranca una ronda nueva (`round_started`) cuando se terminó la actual; devuelve `null` si no queda nadie vivo. Los derrotados se filtran solos por `is_defeated`.
- `TurnOrderBar` / `TurnOrderEntry` (`scenes/ui/combat/`): solo vista (`display(current, remaining, next_round)`); no conocen la cola ni la máquina.
- `scenes/world/sandbox/combat_turns_sandbox.tscn`: escena de depuración que conecta cola, máquina de estados y barra con los reclutas y enemigos de prueba.

## Pendiente
- El "pegamento" entre `TurnQueue` y `CombatStateMachine` vive por ahora en la escena de prueba; pasará al controlador de combate cuando exista la escena de combate real.
- Chequeo de victoria/derrota real: 3.6.
