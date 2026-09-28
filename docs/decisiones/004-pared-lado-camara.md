# 004 - Pared del lado de la cámara

**Fecha:** 2026-09-27 · **Tarea:** fix posterior a 1.4

## Problema
Con la cámara picada fuera de la sala, la pared sur (la más cercana a la cámara) tapaba la parte baja de la pantalla y ocultaba al líder cuando se acercaba a ella.

## Decisión (prototipo)
La pared del lado de la cámara mide **0,5 m de alto**. Sigue bloqueando el paso pero no tapa la vista. Es la solución estándar de HeartGold y juegos de cámara fija.

## A futuro
La preferencia de diseño es que las paredes que tapan al líder se vuelvan transparentes (fade al ocluir). Queda anotado como pendiente en la 4.1 del plan, para resolverlo junto con las plantillas de sala.
