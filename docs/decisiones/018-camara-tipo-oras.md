# 018 - Prueba de cámara de combate tipo ORAS

**Fecha:** 2026-09-29 · **Tarea:** 3.10

## Qué se probó
Una segunda cámara de combate, baja y detrás de los aliados, mirando en diagonal hacia los enemigos (como Pokémon Omega Ruby), además de la vista amplia de la 3.8.

## Cómo funciona
- `PovCamera` (`PhantomCamera3D`) dentro de `CombatController`. Su posición y el punto al que mira salen de `ArenaLayout.get_pov_camera_position()` y `get_pov_look_target()` (lógica pura con tests): detrás del lado aliado, a 9 m del centro, 3,6 m de alto y 4,5 m hacia el espectador; mira 1,5 m pasando el centro hacia los enemigos. FOV 50.
- Si la vista está bloqueada (rayo desde el punto de mira a la cámara o la cámara dentro de la geometría), se usa la vista amplia.
- F2 (tecla de depuración leída en el script, sin tocar el Input Map) alterna entre las vistas; Phantom Camera hace la transición.
- Todos los valores son `@export` del controlador para ajustarlos en el inspector.

## Observaciones
- Con la cámara baja los sprites no se achatan (mejor que la vista picada).
- Unidades de una misma fila pueden superponerse desde el ángulo diagonal, y objetos de la sala (ej. el pedestal) pueden entrar en primer plano.
- El panel inferior del HUD tapa parte de los aliados en primer plano: si se adopta esta vista, el HUD necesita otra distribución.
- Los aliados se ven de frente (placeholders): con arte real harían falta sprites de espalda.

## Pendiente
Decidir jugándolo si reemplaza a la vista amplia o conviven, y si se suman planos de acción, criterios por tipo de combate y opción del jugador (anotado en la 3.10 del plan).
