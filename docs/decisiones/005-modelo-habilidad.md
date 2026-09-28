# 005 - Modelo de datos de las habilidades

**Fecha:** 2026-09-28 · **Tarea:** 2.1

## Reglas de diseño definidas
- **Coste:** una habilidad puede costar maná, estamina, ambos o ninguno, más un cooldown opcional en turnos. El Resource guarda el **coste base**; pasivas del recluta y variantes de arma pueden modificarlo en combate (2.2, 2.3, 3.6).
- **Categoría de daño:** física o mágica. Define qué stats de ataque y defensa usa la fórmula (3.5).
- **Objetivos:** los define cada habilidad (un objetivo, área, aliados, uno mismo…).
- **Efectos en esta etapa:** daño y curación. Empujar, cambiar de fila y estados se suman en la Etapa 3.

## Modelo
- `SkillData` (`scripts/resources/skill_data.gd`): identidad, efecto, categoría, potencia, afinidad, costes, cooldown y objetivo.
- El objetivo combina tres ejes:
  - **Lado:** enemigo, aliado o uno mismo.
  - **Alcance:** solo fila delantera o cualquier fila. Aplica a áreas de un objetivo o fila; el área "todos" lo ignora.
  - **Área:** un objetivo, una fila o todos.
- `AffinityData` (`scripts/resources/affinity_data.gd`): afinidad como Resource en `data/affinities/`, no como enum, para poder sumar familias por tipo de arma (7.4) sin tocar código. Afinidad `null` = neutral.
- `SkillData.validate()` solo hace chequeos estructurales (vacíos, negativos, `SELF` con área distinta de un objetivo). No impone reglas de juego no definidas.

## Pendiente
- Qué pasa si la fila delantera queda vacía con alcance "solo delantera" (3.3).
- Cómo escala la curación y si el bonus de afinidad aplica a curaciones (3.5).
