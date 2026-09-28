# 013 - Fórmula de daño y curación

**Fecha:** 2026-09-28 · **Tarea:** 3.5

## Reglas de diseño definidas
```
Ataque / Defensa  = físicos o mágicos según la categoría de la habilidad
Base              = Potencia × Ataque / Defensa × 0,5          (defensa mínima 1)
Bonus afinidad    = +15% si la habilidad es de la afinidad del usuario
                  + % del arma si es de la afinidad del arma   (se suman)
Reacción          = ×1,25 débil · ×0,75 resistente · ×1 neutral
Daño              = redondear(Base × (1 + Bonus) × Reacción), mínimo 1

Curación          = redondear((Potencia + Ataque / 2) × (1 + Bonus))
```
- Sin azar ni críticos.
- **La fila trasera no reduce el daño**, ni para reclutas ni para enemigos: está protegida solo porque muchas habilidades no la alcanzan. Se actualizó `docs/diseno.md` (Posicionamiento) y el texto de la 3.5 en el plan.
- El bonus de afinidad también aumenta las curaciones.

## Modelo
- `CombatRules` (`scripts/resources/combat_rules.gd`) + `data/combat/combat_rules.tres`: todos los números de balance de la fórmula (0,5 · 15% · 1,25 · 0,75 · mínimo 1 · divisor 2).
- `DamageCalculator` (`scripts/combat/damage_calculator.gd`): `calculate_damage`, `calculate_heal`, `get_affinity_bonus_percent`, `get_amount`. Funciones puras.
- `Combatant` suma `affinity`, `weapon`, `weaknesses`, `resistances` y `get_reaction()`, que reutiliza `EnemyData.reaction_for()`.

## Ejemplos con los datos actuales (provisorios)
| Golpe | Resultado |
|---|---|
| Guerrero · Tajo → Limo (resiste Corte) | 18 |
| Guerrero · Golpe Demoledor → Esqueleto (débil, STAB) | 45 |
| Mago · Bola de Fuego → Limo (débil, STAB) | 92 (mata de un golpe: defensa mágica del Limo muy baja, revisar en 6.2) |
| Mago · Curación Menor | 33 |

## Pendiente
- Aplicar daño/curación a la vida y derrota: 3.6.
- Números sobre las unidades: 3.8.
