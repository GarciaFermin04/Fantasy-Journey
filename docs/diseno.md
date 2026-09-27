# Documento de Diseño - Torre Cambiante (nombre de trabajo)

_Resumen de ideas definidas para el roguelite RPG de fantasía. Documento vivo, no definitivo._

## Concepto General del Juego
_Roguelite RPG de fantasía en una Torre Cambiante_

El juego se plantea como un roguelite RPG de fantasía donde el jugador forma expediciones desde un Reino hacia una Torre misteriosa que cambia entre intentos. La experiencia principal gira alrededor de explorar pisos de la Torre, enfrentar combates por turnos, rescatar o descubrir reclutas, desbloquear armas y artefactos, y regresar al Reino con progreso permanente.

## Estructura Principal
_Reino, Campamento y Torre_

La estructura base se divide en tres espacios. El Reino funciona como lobby explorable y centro de progresión. Allí se eligen reclutas, se gestionan mejoras, se desbloquean armas o artefactos y se interactúa con NPCs. El Campamento funciona como transición y preparación final antes de iniciar la expedición. La Torre es donde empieza oficialmente la run: allí aparecen enemigos, eventos, jefes, salas opcionales y recompensas.

## Reino
_Centro de preparación y progreso permanente_

El Reino será una ciudad explorable, inicialmente pequeña, con opciones de reclutamiento, herrería, tienda, mejoras permanentes, conversaciones y secretos. No debería ser solamente un menú: la idea es que tenga identidad y que crezca o cambie a medida que se desbloquean personajes, recursos y avances de la Torre.

## Campamento
_Preparación final antes de entrar a la Torre_

El Campamento estará ubicado en la entrada de la Torre. Su función será confirmar la expedición, seleccionar equipamiento inicial, revisar consumibles, ver objetivos de la run y comenzar la entrada a la Torre. Los reclutas se eligen previamente en el Reino, no en el Campamento.

## La Torre Cambiante
_Exploración con salas, eventos y combates_

La Torre no será una secuencia simple de piso, combate y siguiente piso. Cada piso deberá poder explorarse, con caminos principales y zonas opcionales. Explorar más suele implicar más combates, más riesgos y más recompensas. La Torre puede incluir enemigos visibles, cofres, runas, trampas, eventos, reclutas, jefes, salas secretas y rutas alternativas. En principio la Torre tendrá entre 4 y 5 pisos; la duración de cada run todavía no está definida.

## Generación de la Torre
_Diseño híbrido recomendado_

La mejor opción inicial parece ser una mezcla entre salas diseñadas a mano y orden variable. Esto permite mantener calidad de diseño sin depender de una generación procedural totalmente compleja. Se pueden crear salas de combate, tesoro, descanso, evento, recluta, trampa y jefe, y luego combinarlas de diferentes formas entre runs.

## Camino Principal y Rutas Opcionales
_Los reclutas cambian oportunidades, no bloquean el avance_

El camino principal de la Torre debería ser accesible con cualquier grupo de reclutas. Los reclutas pueden abrir rutas opcionales, atajos, cofres especiales, salas secretas, eventos de lore o recompensas alternativas. Algunas zonas podrían requerir un recluta específico solo para desbloquearlas por primera vez y luego quedar disponibles en futuras runs.

## Reclutas
_El corazón del sistema de expediciones_

La party máxima será de tres integrantes. La idea actual es que no exista necesariamente un protagonista fijo, sino que la expedición esté formada por tres reclutas. Al principio se pueden usar tres arquetipos clásicos para validar el juego: guerrero, mago y arquero.

## Desbloqueo de Reclutas
_Cada recluta puede tener requisitos propios_

Los reclutas encontrados en la Torre no se desbloquean todos de la misma manera. Algunos pueden desbloquearse simplemente al encontrarlos. Otros pueden requerir derrotar un jefe con ellos en la party, cumplir una misión, sobrevivir a cierta zona, encontrar un objeto o resolver condiciones ocultas. Algunos personajes pueden ser temporales o no reclutables de forma permanente.

## Reclutas Durante una Run
_Interacciones sin depender de una evacuación literal_

Encontrar un recluta en la Torre abre una interacción. Puede unirse temporalmente, quedar marcado como encontrado, desbloquear una condición o simplemente ofrecer diálogo o evento. La idea de “mandarlo al Reino” no tiene que ser una acción literal, sino un estado de desbloqueo o registro para futuras expediciones.

## Reclutas y Exploración
_Identidad fuera del combate_

Los reclutas deberían tener interacciones de exploración. Por ejemplo, una curandera puede activar una runa para curar al grupo, un ladrón puede abrir cofres especiales, un mago puede leer runas arcanas, un guerrero puede romper obstáculos y una exploradora puede revelar zonas ocultas. Estas interacciones deben enriquecer la run sin bloquear el camino principal.

## Equipamiento General
_Poco equipamiento, mucha identidad_

No habrá armadura personalizable. Esto evita micromanagement y mantiene el foco en los reclutas, armas y habilidades. La defensa, resistencia o supervivencia pueden venir de las estadísticas propias del recluta, pasivas, artefactos, habilidades, mejoras permanentes o efectos temporales de la run.

## Sistema de Armas
_Tipos compartidos y variantes_

Los tipos de armas serán compartidos entre reclutas compatibles. Por ejemplo, varios personajes pueden usar varitas, espadas, arcos o grimorios. La diferencia entre personajes vendrá de sus pasivas, habilidades personales, afinidades y rasgos de exploración. Cada tipo de arma tendrá una base común y distintas variantes normales o únicas. Cada recluta solo puede usar ciertos tipos de arma. Las armas se desbloquean de forma permanente y se eligen en el Reino antes de la expedición (a futuro podría sumarse encontrar variantes dentro de la run).

## Variantes Normales y Únicas
_Base común con modificaciones especiales_

Una variante normal parte de un arma base y modifica estadísticas o agrega efectos. Por ejemplo, una Varita base puede tener daño mágico y acceso a habilidades comunes; una Varita Sagrada puede sumar daño sagrado, reducir costes de maná y agregar habilidades sagradas. Las variantes únicas serán armas excepcionales, raras, con nombre propio, pasivas especiales o habilidades exclusivas.

## Habilidades por Arma y Recluta
_Modelo elegido: arma base + recluta + variante_

El sistema preferido es que cada tipo de arma otorgue habilidades base, cada recluta tenga habilidades propias y cada variante agregue habilidades adicionales. Ejemplo: una Varita ofrece 4 hechizos base; el Mago Oscuro aporta 2 hechizos propios; la Varita Sagrada agrega 2 hechizos sagrados. El personaje no usa todas necesariamente, sino que elige 4 o 5 habilidades equipadas.

## Afinidad Tipo STAB
_Compatibilidad simple y clara_

La compatibilidad puede funcionar como en Pokémon: si un recluta usa una habilidad de su afinidad, obtiene un bonus. Por ejemplo, un Mago Oscuro con afinidad Oscuridad hace un 15% más de daño con habilidades oscuras. Esto recompensa la coherencia sin impedir combinaciones raras, como un Mago Oscuro usando una Varita Sagrada.

## Familias de Afinidades
_Tablas por tipo de arma o disciplina_

En lugar de una única tabla universal, cada tipo de arma puede tener su propia familia de afinidades. Varitas podrían usar Fuego, Aire, Tierra, Agua y Rayo. Grimorios podrían usar Vacío, Energía y Alma. Espadas podrían usar estilos marciales como Corte, Guardia o Ruptura. Este sistema debe pensarse tanto a nivel jugable como de lore.

## Debilidades Elementales
_Simples y legibles_

Los enemigos tendrán debilidades y resistencias simples frente a ciertas afinidades. Junto con el bonus tipo STAB, esto hace que elegir qué habilidad usar y con qué recluta sea una decisión táctica. Se busca un sistema corto y fácil de leer, no una tabla compleja.

## Combate
_Turnos individuales estilo RPG clásico_

El combate se plantea por turnos individuales. En lugar de elegir acciones para todos y resolver según velocidad, cada unidad actúa cuando llega su turno: se elige la acción, se ejecuta y luego pasa el turno al siguiente aliado o enemigo. Conviene mostrar una barra de orden de turnos para que las decisiones sean tácticas y claras. El orden lo define la velocidad; una unidad rápida no actúa dos veces salvo que una habilidad u objeto lo permita.

## Posicionamiento
_Dos filas: delantera y trasera_

Cada bando se ubica en dos filas. Los personajes de la fila delantera reciben más ataques y protegen a los de atrás; la fila trasera recibe menos daño y es ideal para magos y arqueros. Algunas habilidades pueden golpear a la fila trasera, empujar o cambiar de fila. Aporta decisiones tácticas sin la complejidad de un sistema de casillas. Al iniciar el combate, los personajes se acomodan en sus filas dentro de la arena de la sala.

## Recursos de Combate
_Maná, estamina y restricciones por turnos_

Las habilidades pueden consumir maná, estamina o tener cooldowns/restricciones por turnos. Los magos pueden depender más del maná, los personajes físicos de la estamina y las habilidades más fuertes de cooldowns. La estamina se recupera una cantidad por turno. El maná no se recarga solo: se recupera en salas de descanso, con pociones o con ciertas habilidades, lo que obliga a los magos a administrarlo durante toda la run. La vida se recupera en salas de descanso, con objetos o con habilidades de curación. La recomendación es mantenerlo simple al principio para no sobrecargar el sistema.

## Transición Exploración-Combate
_Fluida, sin corte como Pokémon_

Los enemigos serán visibles en el mapa o aparecerán mediante eventos. Al entrar en combate, no habrá pantalla negra ni cambio brusco de escena. La cámara se moverá o enfocará la zona, aparecerá la interfaz de combate, se posicionarán los personajes y comenzará el turno correspondiente. El combate ocurre en el mismo espacio de exploración, probablemente dentro de una arena invisible definida por la sala.

## Inicio de Encuentros
_Enemigos visibles, salas y eventos_

Los combates pueden comenzar al tocar un enemigo, entrar en su rango, activar una sala, abrir un cofre, pisar una trampa o iniciar un evento. Si el jugador sorprende al enemigo, puede obtener ventaja inicial. Si el enemigo embosca al grupo, puede actuar primero o aplicar una penalización.

## Progresión Permanente
_Lo que se conserva entre runs_

Se conservan reclutas desbloqueados, armas o artefactos desbloqueados y gemas de la Torre. También podrían conservarse mejoras de edificios, accesos permanentes, avances de lore y vínculos con reclutas. Lo importante es que cada run pueda aportar progreso aunque no se complete.

## Derrota y Fin de Run
_Qué se pierde al caer en la Torre_

Si la expedición es derrotada, se pierde parte del oro obtenido (probablemente entre un 50% y un 75%). Los reclutas no mueren de forma permanente: vuelven al Reino y siguen disponibles para futuras expediciones.

## Loot Durante la Run
_Mejoras temporales que hacen única cada run_

Dentro de la Torre se podrán obtener artefactos, mejoras y objetos temporales que solo duran la run actual. Son la principal fuente de poder dentro de la expedición y lo que hace que cada intento se sienta distinto.

## Economía y Recursos
_Oro, gemas y pocos materiales_

El juego tendrá oro y un recurso especial de la Torre, probablemente gemas. El oro puede servir para compras comunes, consumibles y servicios. Las gemas deberían usarse para mejoras permanentes, desbloqueos importantes o avances del Reino. También pueden existir materiales para mejorar armas, pero conviene mantener pocos tipos para evitar complejidad excesiva.

## Vínculo con Reclutas
_Progresión propia de cada recluta_

Puede existir una mecánica de afinidad o vínculo con los reclutas. No debería ser un sistema social demasiado complejo. Podría subir al usarlos en runs, completar eventos personales o cumplir condiciones especiales. Se llama Vínculo para no confundirlo con la Afinidad elemental. Tendrá pocos niveles con hitos claros, por ejemplo: nivel 2 pasiva menor, nivel 3 nueva habilidad o hechizo, nivel 4 diálogo o lore, nivel 5 quest personal o secreta con una recompensa única. Lo que desbloquea debe dar variedad, no mejoras obligatorias, para evitar el grindeo.

## Estilo Visual
_Inspiración HeartGold/Platino con proporciones menos chibi_

El estilo visual apunta a un híbrido 2D/3D inspirado en Pokémon HeartGold o Pokémon Platino, pero con personajes menos chibi. La prioridad será claridad visual, lectura de combate y coherencia estética. Se busca una fantasía estilizada, no realista oscura tipo Dark Souls.

## Alcance Inicial de Desarrollo
_Prototipo interno antes del juego completo_

Aunque la intención sea lanzar un juego completo al público, el desarrollo debería comenzar con una versión pequeña para validar sistemas: tres reclutas clásicos, uno o dos tipos de arma, pocas variantes, un piso de Torre, varios enemigos, un jefe, una zona del Reino y una transición funcional entre exploración y combate.

## Plataforma y Desarrollo
_Godot Engine, PC/Steam_

El juego se desarrollará en Godot Engine, por un solo desarrollador con asistencia de Claude Code. La plataforma inicial es PC/Steam con teclado. El principal riesgo de producción es el arte 2D/3D: conviene definir temprano su origen (assets, estilo low-poly simple o un artista) y usar formas básicas durante el prototipo.

## Nombre y Lore
_Pendiente de definir_

El juego todavía no tiene nombre definitivo; "Torre Cambiante" es un nombre de trabajo. La Torre también tendrá un lore propio, incluyendo por qué cambia entre intentos.

## Idea Núcleo
_Frase guía del proyecto_

Un roguelite RPG de fantasía donde formas expediciones de tres reclutas desde un Reino, exploras una Torre cambiante, peleas en combates por turnos individuales, desbloqueas personajes y armas, y cada run revela nuevas oportunidades, secretos y progreso permanente.
