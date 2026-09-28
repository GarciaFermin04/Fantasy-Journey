# 015 - IA enemiga simple

**Fecha:** 2026-09-28 · **Tarea:** 3.7

## Reglas de diseño definidas
- **Habilidad:** sorteo ponderado (pesos de `EnemySkillEntry`) entre las habilidades usables: con objetivos válidos y fuera de enfriamiento.
- **Objetivo:**
  - **Al azar:** sorteo entre las opciones válidas; las que incluyen unidades de la fila delantera pesan el doble (`CombatRules.ai_front_row_weight = 2`). Implementa "la fila delantera recibe más ataques" para habilidades que alcanzan cualquier fila.
  - **Menos vida:** la opción con la unidad de menor **vida actual**; empate → orden de formación.
- Si no puede hacer nada, pasa el turno.

## Por qué lógica propia y no LimboAI
- La decisión es una por turno: un sorteo ponderado y una regla de objetivo. Un Behavior Tree (`BTPlayer`, blackboard, ticks por frame en el árbol de escena) sobra para eso.
- CLAUDE.md pide lógica de reglas testeable sin escenas: `EnemyAI.choose_action()` es una función pura.
- Para jefes con fases o mecánicas propias (4.7) se reevalúa LimboAI; una tarea de Behavior Tree podría llamar a esta misma lógica.

## Modelo
- `WeightedPicker.pick_index(weights, rng)` (`scripts/combat/ai/`): sorteo ponderado genérico.
- `EnemyAI.choose_action(actor, own_side, other_side, rules, rng)` (`scripts/combat/ai/`): devuelve un `CombatAction` o `null`.
- El azar se inyecta con un `RandomNumberGenerator`: aleatorio en el juego, semilla fija en los tests.
- `Combatant.skill_weights` y `Combatant.target_preference`, copiados desde `EnemyData` en `from_enemy`.

## Pendiente
- IA más inteligente (buscar debilidades, curarse) si el balance lo pide (6.2).
- IA de jefes (4.7).
