# 006 - Modelo de armas, tipos de arma y stats

**Fecha:** 2026-09-28 · **Tarea:** 2.2

## Reglas de diseño definidas
- **Stats de personaje:** Vida, Maná, Estamina, Ataque, Ataque mágico, Defensa, Defensa mágica, Velocidad.
- **Variantes:** modifican stats con bonus fijos (pueden ser negativos).
- **Afinidad del arma:** un arma puede tener afinidad y potencia las habilidades de esa afinidad, como un segundo STAB. El porcentaje es un dato de cada arma; cómo se combina con el +15% del recluta se define en la fórmula (3.5).
- **Coste de habilidades:** un arma puede cambiar el coste de maná/estamina de cada habilidad con un modificador fijo (ej. −2 maná por habilidad). El coste final nunca baja de 0 (se aplica en 3.6).
- **Armas únicas:** algunas son variantes de un tipo existente; otras traen su propio tipo exclusivo, con habilidades base propias.

## Modelo
- `StatBlock`: los 8 stats. Una sola clase para stats base de reclutas y enemigos y para bonus de armas. `plus()` suma bloques.
- `WeaponTypeData`: tipo de arma (Varita, Espada…) con sus habilidades base. Va en `data/weapons/types/`.
- `WeaponData`: arma equipable con `rarity` (`BASE`, `VARIANT`, `UNIQUE`), tipo, bonus de stats, afinidad y su bonus, modificadores de coste y habilidades extra. `get_all_skills()` devuelve base del tipo + extra sin repetir; el recluta elige de ahí sus 4-5 equipadas.
- Una única de tipo propio = un `WeaponTypeData` exclusivo + un `WeaponData` `UNIQUE` que lo usa. No hace falta otra clase.
- Carpetas: `data/weapons/types/` (tipos), `base/` (armas comunes), `variants/` y `unique/`.
- `tests/unit/resources/test_data_files.gd` valida todos los `.tres` de `data/` que tengan `validate()`.

## Pendiente
- Pasivas especiales de armas únicas (cuando exista el sistema de pasivas, 2.3).
- Familias de afinidad por tipo de arma (7.4).
