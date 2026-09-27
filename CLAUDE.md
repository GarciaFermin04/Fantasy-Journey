# CLAUDE.md

Roguelite RPG por turnos (nombre de trabajo: "Torre Cambiante"). Godot 4.7, GDScript.

## Diseño

- Leer `docs/diseno.md` antes de implementar cualquier sistema de juego.
- Las decisiones de diseño relevantes se registran en `docs/decisiones/`.

## Estructura

- Respetar la estructura de carpetas existente. Si algo no encaja, proponer dónde va **antes** de crear carpetas nuevas.
- Los scripts adjuntos a una escena viven al lado de su `.tscn`. En `scripts/` solo va lógica pura y reutilizable, sin escena asociada.
- Datos del juego como Resources (`.tres`) en `data/`, nunca hardcodeados. Sus clases se definen en `scripts/resources/`.
- No editar la carpeta `.godot/`.
- `demo/` es el demo de LimboAI, no es código del juego.

## Código

- GDScript con tipado estático siempre (variables, parámetros y retornos).
- Archivos en `snake_case`; `class_name` en `PascalCase`.
- Usar señales y el autoload `event_bus` para desacoplar sistemas. Autoloads solo para estado global.
- Toda la lógica de combate (daño, afinidad, debilidades, turnos) va separada de las escenas, en `scripts/combat/`, con tests en `tests/unit/combat/`.

## Tests

Correr los tests después de cambios en lógica:

```
godot --headless -s addons/gut/gut_cmdln.gd -gdir=res://tests -ginclude_subdirs -gexit
```

`godot` no está en el PATH; el ejecutable está en
`C:\Steam\steamapps\common\Godot Engine\godot.windows.opt.tools.64.exe`.
Los tests usan GUT (`addons/gut`), extienden `GutTest` y sus archivos empiezan con `test_`.

## Git

- Cambios chicos, un commit por feature.
- Mensajes de commit en español.
