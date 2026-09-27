# 001 - Tamaño de la sala base

**Fecha:** 2026-09-27 · **Tarea:** 1.1

## Decisión
La sala greybox mide **16 × 12 m de interior**, con paredes de **3 m de alto** y 0,5 m de grosor. El suelo tiene la superficie en `y = 0`. Se toma como referencia de tamaño para las plantillas de sala (4.1).

## Por qué
- Un combate 3 vs 3 en dos filas por bando ocupa unos 10 × 6 m. El resto deja margen para rodear obstáculos y para que la cámara no quede pegada a las paredes.
- Las paredes son bajas porque la cámara es picada: paredes altas taparían al personaje.
- Los obstáculos van hacia los bordes para dejar libre el centro, donde irá la arena de combate.

## Detalles de implementación
- Toda la geometría cuelga de un `CSGCombiner3D` con `use_collision` activado: genera un único cuerpo estático en la capa `world`.
- Colores planos como materiales compartidos en `assets/materials/greybox_*.tres`.
