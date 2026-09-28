# Plan de desarrollo

Estados: [x] hecho · [~] en curso · [ ] pendiente. Actualizar al terminar cada tarea.

## Etapa 0: Preparación (~10 h)
**Lista cuando:** el proyecto abre en Godot, está en GitHub y Claude Code entiende sus reglas.

- [x] **0.1 Instalar Godot 4 (última estable)** — Usar GDScript, no C#: hay más ejemplos y mejor soporte en el editor.
- [x] **0.2 Crear repo Git + GitHub** — .gitignore de Godot. Commits chicos y frecuentes.
- [x] **0.3 Estructura de carpetas** — scenes/, scripts/, data/, assets/placeholder/. Código en inglés, textos del juego en español.
- [x] **0.4 Escribir CLAUDE.md** — Resumen del diseño, convenciones y reglas. Es lo que Claude Code lee en cada sesión.
- [x] **0.5 Pasar el diseño al repo** — docs/diseno.md con el contenido del PDF, para que Claude Code lo tenga de referencia.

## Etapa 1: Exploración base (~25 h)
**Lista cuando:** movés un sprite por una sala 3D de cubos con cámara estilo HeartGold y podés interactuar con un objeto.

- [x] **1.1 Sala greybox** — Piso y paredes con cubos (CSGBox3D). Nada de arte todavía.
- [x] **1.2 Personaje sprite billboard** — Sprite3D con un rectángulo de color. Se reemplaza cuando haya arte.
- [x] **1.3 Movimiento con teclado** — 8 direcciones y colisiones con paredes.
  - Input Map: `move_up/down/left/right` (WASD + flechas), `interact` (E, Enter, Enter numérico).
- [x] **1.4 Cámara fija inclinada** — Vista picada que sigue al líder, sin rotación libre. Es la base del estilo HeartGold/Platino.
- [x] **1.5 Party que sigue al líder** — Los otros 2 reclutas caminan detrás. Si complica, mostrar solo al líder por ahora.
- [x] **1.6 Interacción básica** — InteractableComponent reutilizable + un objeto de prueba en la sala. Tecla de interacción, mostrar un aviso simple al acercarse y una respuesta al interactuar (print o label). Es la base para cofres, runas y NPCs.

## Etapa 2: Datos del juego (~15 h)
**Lista cuando:** guerrero, mago y arquero existen como archivos de datos con sus armas y habilidades.

- [x] **2.1 Resource de Habilidad** — Coste de maná o estamina, cooldown, daño, afinidad y a qué fila puede apuntar.
- [x] **2.2 Resource de Arma y Variante** — Tipo y habilidades base. La variante suma stats y habilidades extra.
- [x] **2.3 Resource de Recluta** — Stats, afinidad, armas permitidas, habilidades propias y rasgo de exploración.
  - Pendiente: pasivas (recluta, Vínculo, armas únicas). Diseñarlas en la Etapa 3, cuando haya combate.
- [x] **2.4 Resource de Enemigo** — Stats, debilidades, resistencias, habilidades y patrón simple de IA.
- [x] **2.5 Crear los 3 reclutas** — Guerrero con espada, mago con varita, arquero con arco. 4 habilidades equipadas cada uno.

## Etapa 3: Combate por turnos (~50 h)
**Lista cuando:** una pelea 3 vs 3 arranca al tocar un enemigo, se juega completa en la misma sala y vuelve a la exploración.

- [ ] **3.1 Máquina de estados del combate** — Inicio, turno, acción, fin. Es la pieza más importante del juego: hacerla con calma.
- [ ] **3.2 Cola de turnos por velocidad** — Más la barra visible con el orden de turnos.
- [ ] **3.3 Filas delantera y trasera** — Ubicar aliados y enemigos. Solo ciertas habilidades alcanzan la fila trasera.
- [ ] **3.4 Menú de acciones** — Habilidad, objeto, cambiar de fila. Todo con teclado.
- [ ] **3.5 Fórmula de daño** — Base + afinidad (+15%) + debilidad o resistencia + reducción por fila trasera.
- [ ] **3.6 Vida, maná y estamina** — La estamina recupera por turno, el maná no. Cooldowns por turnos.
- [ ] **3.7 IA enemiga simple** — Elegir habilidad y objetivo con reglas básicas.
- [ ] **3.8 Transición sin corte** — Tocar enemigo, la cámara enfoca la sala, aparece la UI y las unidades se acomodan.
- [ ] **3.9 Sorpresa y emboscada** — Atacar por la espalda da ventaja. Ser emboscado da el primer turno al enemigo.

## Etapa 4: Primer piso de la Torre (~40 h)
**Lista cuando:** jugás un piso completo con salas variables, loot temporal y un jefe al final.

- [ ] **4.1 Plantillas de sala** — Combate, tesoro, descanso, evento, recluta y jefe. Cada una es una escena hecha a mano.
  - Pendiente: la pared del lado de la cámara hoy es baja (0,5 m) como solución de prototipo. La preferencia es reemplazarla por paredes que se vuelven transparentes cuando tapan al líder.
- [ ] **4.2 Generador de piso híbrido** — Orden variable de salas: camino principal + ramas opcionales.
- [ ] **4.3 Puertas y paso entre salas** — Entrar y salir de salas sin cortes bruscos.
- [ ] **4.4 Sala de descanso** — Recupera vida y maná. Clave para que el maná sin recarga funcione.
- [ ] **4.5 Loot temporal de run** — 5-8 artefactos simples que duran solo la run.
- [ ] **4.6 Interacción por recluta** — Guerrero rompe obstáculo, mago lee runa, arquero alcanza algo lejano. Abre ramas, nunca bloquea el camino.
- [ ] **4.7 Jefe del piso** — Un enemigo con dos fases o una mecánica propia.

## Etapa 5: Loop completo: Reino y Campamento (~30 h)
**Lista cuando:** salís del Reino, entrás a la Torre, ganás o perdés, y volvés con progreso guardado.

- [ ] **5.1 Zona chica del Reino** — Explorable, con 2-3 NPCs: reclutamiento y herrería.
- [ ] **5.2 Elegir reclutas y armas** — Selección de los 3 reclutas y su arma antes de salir.
- [ ] **5.3 Campamento** — Confirmar expedición, consumibles y entrar a la Torre.
- [ ] **5.4 Oro y gemas** — Oro para consumibles, gemas para 1-2 mejoras permanentes de prueba.
- [ ] **5.5 Derrota: pérdida de oro** — Se pierde 50-75% del oro. Los reclutas vuelven al Reino.

## Etapa 6: Validación del prototipo (~15 h)
**Lista cuando:** sabés qué es divertido, qué sobra y qué cambiar del diseño.

- [ ] **6.1 Jugar 10 runs y anotar** — Qué aburre, qué cuesta y qué decisiones importan.
- [ ] **6.2 Balance básico** — Daño, vida, costes y cantidad de combates por piso.
- [ ] **6.3 Que lo pruebe otra persona** — Mirar sin explicar. Lo que no entiende es un problema de diseño.

## Etapa 7: Producción
**Lista cuando:** se planifica en detalle al terminar la validación.

- [ ] **7.1 Definir origen del arte** — Assets comprados, low-poly propio o artista. Es el mayor riesgo del proyecto.
- [ ] **7.2 Pisos 2 a 5** — Nuevas salas, enemigos y jefes.
- [ ] **7.3 Más reclutas y desbloqueo condicional** — Reclutas que se ganan con jefes, misiones o condiciones ocultas.
- [ ] **7.4 Familias de afinidad por arma** — Varitas, grimorios y espadas con su propia tabla.
- [ ] **7.5 Sistema de Vínculo** — Pocos niveles con hitos claros, sin grindeo.
- [ ] **7.6 Nombre, lore y por qué cambia la Torre**
- [ ] **7.7 Audio, menús y opciones**
