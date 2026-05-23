"""extends Node2D

var player: CharacterBody2D

var ulti_center: Vector2
var ulti_angle := 0.0
var ulti_radius := 100.0
var ulti_speed := 8.0


func start(p: CharacterBody2D):
	player = p
	ulti_center = player.global_position
	ulti_angle = 0
	GameManager.ult_tries+=1


func ulti_move(delta: float) -> void:
	if player == null:
		return
		
	ulti_angle += delta * ulti_speed
	
	var offset = Vector2(
		cos(ulti_angle),
		sin(ulti_angle)
	) * ulti_radius
	
	player.global_position = ulti_center + offset"""

extends Node2D

var player: CharacterBody2D
var ulti_center: Vector2
var ulti_angle := 0.0
var ulti_radius := 100.0
var ulti_speed := 8.0

func start(p: CharacterBody2D):
    player = p
    ulti_center = player.global_position
    ulti_angle = 0.0
    GameManager.ult_tries += 1

func ulti_move(delta: float) -> void:
    if player == null:
        return

    ulti_angle += delta * ulti_speed

    # Posición objetivo en el círculo
    var target_pos = ulti_center + Vector2(
        cos(ulti_angle),
        sin(ulti_angle)
    ) * ulti_radius

    # Convertir diferencia de posición en velocidad
    player.velocity = (target_pos - player.global_position) / delta
    player.move_and_slide()
