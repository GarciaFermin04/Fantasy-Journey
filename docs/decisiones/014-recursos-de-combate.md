# 014 - Vida, maná, estamina y enfriamientos

**Fecha:** 2026-09-28 · **Tarea:** 3.6

## Reglas de diseño definidas
- **Estamina:** al empezar su propio turno, cada unidad recupera el 20% de su máximo (`CombatRules.stamina_regen_percent`).
- **Inicio de combate:** estamina llena. Vida y maná se arrastran entre combates durante la run (el diseño ya lo decía). Hasta que exista el estado de la run, todos arrancan llenos; `Combatant.start_combat(hp, mana)` ya permite pasar valores iniciales.
- **Enemigos:** usan sus habilidades gratis (`CombatRules.enemies_pay_costs = false`).
- **Enfriamiento en turnos propios:** enfriamiento N bloquea los próximos N turnos propios. Usada en el turno T, vuelve en T+N+1.
- **Costes:** base + modificador del arma, mínimo 0.
- **Derrota:** a 0 de vida. La curación no supera el máximo ni revive. Victoria si caen todos los enemigos; derrota si caen todos los aliados.

## Modelo
- `Combatant`: `current_hp`, `current_mana`, `current_stamina`, enfriamientos. `take_damage`, `heal`, `get_mana_cost`, `get_stamina_cost`, `can_use`, `pay_for`, `start_turn` (regenera estamina), `end_turn` (avanza enfriamientos, salvo el de la habilidad recién usada), `get_cooldown_remaining`, `start_combat`.
- `ActionResolver.resolve(action, rules)`: cobra el coste, aplica daño/curación con `DamageCalculator` y devuelve `ActionResult` por objetivo (cantidad real, curación, reacción, derrotado).
- `CombatOutcome.evaluate(allies, enemies)` + `Formation.is_wiped_out()`.
- El menú deshabilita habilidades sin recursos o en enfriamiento y muestra el coste real del actor y "faltan N turnos".

## Pendiente
- Estado de la run que guarde vida y maná entre combates (Etapa 4/5).
- Barras de vida y números sobre las unidades (3.8).
