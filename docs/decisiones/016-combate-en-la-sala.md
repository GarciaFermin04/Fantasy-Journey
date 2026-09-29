# 016 - Combate en la sala (transición sin corte)

**Fecha:** 2026-09-29 · **Tarea:** 3.8a, 3.8b y 3.8c

## Reglas de diseño definidas
- **Cada enemigo visible es una unidad.** Al tocar uno, entran al combate los enemigos dentro de un radio del tocado (`encounter_radius`, 6 m en la sala de prueba).
- **La arena se arma alrededor del choque.** Centro = punto medio entre el líder y el enemigo tocado. Eje horizontal de pantalla (X del mundo): aliados del lado donde estaba el líder, enemigos del otro. Fila delantera a 1,5 m del centro, trasera 1,5 m más afuera; las unidades de una fila se reparten en profundidad (Z) a 2 m.
- **Lugares bloqueados:** si un lugar cae dentro de la geometría (capa `world`), se corre hacia el centro en pasos de 0,25 m hasta quedar libre.
- **Las unidades caminan a su lugar** (~0,5 s) mientras la cámara enfoca.
- **Derrota:** mensaje y recarga de la sala (3.8c).

## Modelo
- `RoomEnemy` (`scenes/agents/enemies/common/`): enemigo visible con `EnemyData`; su `Area3D` solo detecta la capa `player` y emite `touched`.
- `EncounterGatherer` (`scripts/exploration/`): qué enemigos entran por radio.
- `CombatSession` (`scripts/combat/`): el combate como lógica pura (formaciones, cola, máquina de estados, resolución, regeneración, enfriamientos, victoria/derrota) con señales `turn_started`, `action_performed`, `combat_finished`. Lo usan la escena de prueba y el controlador; ambos quedan solo con la presentación.
- `ArenaLayout` (`scripts/combat/`): posiciones por fila y corrección de lugares bloqueados (`resolve_slot` con un `Callable` de "está libre", testeable sin física).
- `CombatController` (`scenes/combat/`): crea los `Combatant` desde la party y los `RoomEnemy`, mueve cada nodo con `Tween`, activa una `PhantomCamera3D` de combate (prioridad 20, transición 0,6 s) y muestra el `CombatHud`. Emite `combat_finished`.
- `CombatHud` (`scenes/ui/combat/`): barra de turnos, estado de las unidades, log y panel de comandos.
- `CombatText` (`scripts/utils/`): textos de estado y resultados compartidos por las pantallas de combate.
- `Party.set_exploration_enabled(false)` también apaga el `_physics_process` de los miembros para que el `Tween` pueda moverlos.

## Fin del combate (3.8c)
- Se muestra "¡Victoria!" o "Derrota..." durante 1,2 s.
- **Victoria:** la cámara de combate baja su prioridad (vuelve la de exploración), se oculta el HUD, los enemigos derrotados se eliminan de la sala, los demás vuelven a poder disparar encuentros y la party retoma el control; el rastro de los seguidores se reinicia detrás del líder.
- **Derrota:** mensaje y recarga de la sala.
- Números de daño flotantes (`DamageNumber`): blanco daño, naranja con "!" débil, gris resistido, verde "+" curación.
- Enemigos derrotados se desvanecen del todo; aliados derrotados quedan semitransparentes y vuelven a verse normales al ganar.
- Vida y maná todavía no se arrastran entre combates (falta el estado de la run, 4.4).

## Pendiente
- Ajuste fino de presentación: el nombre de una unidad puede superponerse con la de atrás, y una unidad puede quedar delante de un obstáculo. Revisar cuando haya arte (7.1) o antes si molesta.
