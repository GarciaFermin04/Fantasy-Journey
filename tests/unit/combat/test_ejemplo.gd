extends GutTest
## Test de ejemplo para verificar que GUT está funcionando.


func test_suma_basica() -> void:
	var resultado: int = 2 + 2
	assert_eq(resultado, 4, "2 + 2 debería ser 4")


func test_verdadero_es_verdadero() -> void:
	assert_true(true)
