# 002 - Sprites de personaje con billboard Fixed Y

**Fecha:** 2026-09-27 · **Tarea:** 1.2

## Decisión
Los `Sprite3D` de personajes usan `billboard = FIXED_Y` (giran solo sobre el eje vertical) y `alpha_cut = DISCARD`. El origen de la escena visual está en los pies.

## Por qué
- La cámara de exploración es picada (~45°) y sin rotación libre. Con `ENABLED` el sprite se inclinaría hacia atrás para mirar a la cámara: los pies se despegan del piso, atraviesa paredes cercanas y su sombra se deforma.
- Con `FIXED_Y` el sprite queda siempre vertical: apoyado en el piso, con sombra coherente y buen ordenamiento de profundidad contra paredes y obstáculos. Es el enfoque de HeartGold/Octopath.
- Costo: la perspectiva picada lo acorta un poco. Si molesta, se compensa con `pixel_size` o con el ángulo de la cámara (1.4).
- `alpha_cut = DISCARD` permite que proyecte sombra y evita problemas de orden de dibujado con arte transparente.

## Cómo reemplazar el placeholder
- Arte estático: cambiar `assets/sprites/recruits/placeholder_recruit.tres` por la textura real (y ajustar `offset.y` a media altura en píxeles).
- Animaciones: cambiar el nodo `Sprite3D` de `scenes/agents/recruits/recruit_visual.tscn` por un `AnimatedSprite3D`.
