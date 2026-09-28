# 011 - Filas delantera y trasera

**Fecha:** 2026-09-28 · **Tarea:** 3.3

## Reglas de diseño definidas
- **Fila delantera vacía:** si en un bando no queda nadie adelante, la fila trasera queda expuesta a todo, incluidas las habilidades de "solo fila delantera".
- **Capacidad:** reclutas aliados hasta 3 por fila. Los enemigos no tienen límite.
- **Cambio de fila:** no hay cambio manual. Solo mediante habilidades ("empujar", "cambiar de fila"), que se sumarán como efectos de habilidad. El menú de la 3.4 queda en "Habilidad y objeto".

## Modelo
- `Combatant.row`: fila actual (inicia en la fila preferida del recluta o enemigo). `Combatant.skills`: habilidades que puede usar en el combate (equipadas del recluta o habilidades del enemigo).
- `Formation` (`scripts/combat/formation.gd`): un bando. `max_per_row` (0 = sin límite), `add`, `get_row`, `get_living`, `is_back_row_exposed`, `move_to_row` (para habilidades futuras). Los derrotados no ocupan lugar.
- `Targeting.get_target_options(skill, user, own_side, other_side)` (`scripts/combat/targeting.gd`): devuelve las opciones elegibles; cada opción es el grupo de unidades afectadas.
  - Lado: `ENEMY` → bando contrario; `ALLY` → propio; `SELF` → solo el usuario.
  - Alcance: `FRONT_ROW` → fila delantera, o trasera si la delantera está vacía; `ANY_ROW` → ambas.
  - Área: `SINGLE` → una opción por unidad; `ROW` → una por fila alcanzable no vacía; `ALL` → todos los vivos (ignora alcance).

## Queda para otras tareas
- Reducción de daño en la fila trasera: fórmula (3.5).
- "La fila delantera recibe más ataques": preferencia de la IA (3.7).
- Ubicar a las unidades en el espacio 3D de la sala: 3.8.
