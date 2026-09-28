# 012 - Menú de acciones y selector de objetivo

**Fecha:** 2026-09-28 · **Tarea:** 3.4

## Reglas de diseño definidas
- **Menú plano:** las 4 habilidades del actor + "Objeto" en una sola lista. "Objeto" visible y deshabilitado hasta que existan los consumibles.
- **Sin otros comandos:** no hay pasar turno ni defender. Cada recluta tiene un ataque gratis, así que siempre puede actuar.
- **Flujo:** habilidad → objetivo → confirmar. Escape vuelve del objetivo a la lista con el foco en la habilidad elegida.
- **Teclado:** acciones `ui_*` nativas (flechas, Enter, Escape) vía el sistema de foco de Godot; sin cambios al Input Map. El mouse también funciona.

## Modelo
- `CombatAction` (`scripts/combat/combat_action.gd`): usuario, habilidad y objetivos. Es lo que recibe `CombatStateMachine.submit_action()` y lo que resolverá la fórmula (3.5).
- `ActionMenu` (`scenes/ui/combat/action_menu.tscn`): lista de habilidades + "Objeto" y panel con coste, enfriamiento, objetivo y descripción de la habilidad enfocada. Una habilidad sin objetivos válidos aparece deshabilitada.
- `TargetSelector` (`scenes/ui/combat/target_selector.tscn`): opciones de `Targeting` (una unidad, una fila entre corchetes o todos).
- `CombatCommandPanel` (`scenes/ui/combat/combat_command_panel.tscn`): une ambos con fases explícitas `HIDDEN → CHOOSING_SKILL → CHOOSING_TARGET → HIDDEN`, y emite `action_confirmed(action)`.

## Pendiente
- Deshabilitar habilidades sin recursos o en enfriamiento: 3.6.
- Marcador de objetivo sobre la unidad en la sala 3D: 3.8.
- Consumibles e inventario para habilitar "Objeto".
