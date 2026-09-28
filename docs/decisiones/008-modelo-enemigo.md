# 008 - Modelo de datos de los enemigos

**Fecha:** 2026-09-28 · **Tarea:** 2.4

## Reglas de diseño definidas
- **Reacción a afinidades:** débil, resistente o neutral. Sin inmunidades ni absorción. Los multiplicadores se definen en la fórmula (3.5).
- **Afinidad propia:** opcional, con bonus tipo STAB igual que los reclutas.
- **Patrón de IA en datos:** cada habilidad con un peso relativo + una preferencia de objetivo (`RANDOM`, `LOWEST_HP`). En la 3.7 se decide si LimboAI ejecuta estas reglas.
- **Jefes:** mismo Resource con `is_boss`. Fases o mecánicas propias en la 4.7.

## Modelo
- `EnemyData`: identidad (+ `sprite`, `is_boss`), stats base, afinidad, fila preferida, debilidades, resistencias, habilidades con peso y preferencia de objetivo.
  - `get_reaction(affinity)`: `NEUTRAL`, `WEAK` o `RESISTANT` (afinidad `null` = neutral).
  - `get_skills()`: habilidades sin pesos.
- `EnemySkillEntry`: habilidad + peso, como sub-recurso dentro del `.tres` del enemigo (no un archivo por entrada, y no listas paralelas que se puedan desalinear).
- `StatBlock.validate_as_base_stats()`: validación de stats base compartida por reclutas y enemigos.

## Pendiente
- Elección ponderada de habilidad y objetivo (lógica de IA): 3.7.
- Recompensas (oro, gemas, loot table): 4.5 / 5.4.
- Enemigos de prueba como `.tres`: al empezar la Etapa 3 (no hay tarea que los cree en la Etapa 2).
