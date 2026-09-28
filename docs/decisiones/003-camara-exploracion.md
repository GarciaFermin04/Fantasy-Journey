# 003 - Cámara de exploración con Phantom Camera

**Fecha:** 2026-09-27 · **Tarea:** 1.4

## Decisión
- Una sola `Camera3D` real con `PhantomCameraHost` (`scenes/camera/main_camera.tscn`). Las situaciones de cámara son `PhantomCamera3D` separadas que compiten por prioridad.
- Cámara de exploración (`scenes/camera/exploration_camera.tscn`): `follow_mode = SIMPLE`, `follow_offset = (0, 7, 8.5)`, rotación `(-40°, 0, 0)`, damping `0.1`, FOV 40° vía `Camera3DResource`, `priority = 10`.
- La `PhantomCamera3D` vive en la sala, no dentro del líder: la sala asigna `follow_target`.
- `physics/common/physics_interpolation` activado en Project Settings.

## Por qué
- Host único + cámaras virtuales por situación: en la 3.8 el enfoque de combate será otra `PhantomCamera3D` con más prioridad y el addon hace la transición.
- `SIMPLE` sigue siempre al líder a distancia fija, como HeartGold. `FRAMED` (zona muerta, estilo Zelda) queda como alternativa cambiando una propiedad.
- 40° en vez de 45°: con billboard `FIXED_Y`, cuanto más picada la cámara, más achatado se ve el sprite (77% de su alto a 40°, 71% a 45°).
- FOV cerrado (40°): menos deformación de perspectiva, look más "2.5D". Va en la cámara virtual para que cada una defina su encuadre.
- Interpolación física: el líder se mueve en `_physics_process`; sin interpolación la cámara tiembla en monitores de más de 60 Hz. Phantom Camera lo recomienda.
