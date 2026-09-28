# 007 - Modelo de datos de los reclutas

**Fecha:** 2026-09-28 · **Tarea:** 2.3

## Reglas de diseño definidas
- **Afinidad:** cada recluta tiene una sola.
- **Pasivas:** se diseñan más adelante (Etapa 3), junto con las de Vínculo y armas únicas.
- **Habilidades equipadas:** máximo 4 para todos (`RecruitData.MAX_EQUIPPED_SKILLS`).
- **Fila:** cada recluta tiene una fila preferida en sus datos; más adelante el jugador arma su formación.
- **Stats fijos:** el diseño no menciona niveles ni experiencia (la progresión del recluta es el Vínculo).

## Modelo
- `RecruitData`: identidad (+ `sprite` opcional), stats base (`StatBlock`), afinidad, fila preferida, tipos de arma permitidos, habilidades propias, rasgo de exploración y equipamiento por defecto (arma + hasta 4 habilidades).
  - `can_use_weapon()`, `get_available_skills(weapon)` (arma + propias, sin repetir) y `get_stats_with(weapon)` (base + bonus del arma).
  - El equipamiento por defecto sirve para la 2.5 y para probar el combate; lo que el jugador elija en el Reino (5.2) será progreso guardado, no dato fijo.
- `CombatRow`: `enum Row { FRONT, BACK }` en archivo propio, compartido por reclutas, enemigos y combate.
- `ExplorationTraitData`: rasgo de exploración como Resource en `data/exploration_traits/`. Un rasgo por recluta, opcional en los datos. Las interacciones de la 4.6 comparan contra él.

## Pendiente
- Pasivas (recluta, Vínculo, armas únicas): Etapa 3.
- Condiciones de desbloqueo y reclutas temporales: 7.3.
- Formación elegida por el jugador y equipamiento guardado: 5.2.
