"""extends Node2D

var player: CharacterBody2D
var dash_direction := Vector2.ZERO
var isActive : bool = false
var dash_speed := 700.0
var dash_time := 3.0
var elapsed := 0.3

var amplitude := 100.0     # qué tan abierto es el zigzag
var waves := 2.0           # cuántas ondas
var zigzag_start_time := 0.1  # cuándo empieza el zigzag

var start_position := Vector2.ZERO


func start(p: CharacterBody2D):
	player = p
	elapsed = 0
	start_position = player.global_position
	isActive = true

	var flip := player.get_node("Flip")
	var dir = flip.scale.x

	dash_direction = Vector2(dir, 0)

	GameManager.ult_tries+=1


func ulti_move(delta: float) -> void:
	if player == null or not isActive:
		return


	elapsed += delta

	var perpendicular = dash_direction.orthogonal()

	var forward = dash_direction * dash_speed * elapsed

	var zigzag := Vector2.ZERO

	if elapsed > zigzag_start_time:
		var t = elapsed - zigzag_start_time
		zigzag = perpendicular * sin(t * waves * PI * 2) * amplitude

	player.global_position = start_position + forward + zigzag

	if elapsed >= dash_time:
		isActive = false
		player.velocity = Vector2.ZERO
		player._finish_ulti_recovery()"""

extends Node2D

var player: CharacterBody2D
var dash_direction := Vector2.ZERO
var isActive : bool = false
var dash_speed := 700.0
var dash_time := 3.0
var elapsed := 0.3
var amplitude := 100.0
var waves := 2.0
var zigzag_start_time := 0.1
var start_position := Vector2.ZERO

func start(p: CharacterBody2D):
    player = p
    elapsed = 0
    start_position = player.global_position
    isActive = true
    var flip := player.get_node("Flip")
    var dir = flip.scale.x
    dash_direction = Vector2(dir, 0)
    GameManager.ult_tries += 1

func ulti_move(delta: float) -> void:
    if player == null or not isActive:
        return

    elapsed += delta

    var perpendicular = dash_direction.orthogonal()
    var forward = dash_direction * dash_speed * elapsed
    var zigzag := Vector2.ZERO
    if elapsed > zigzag_start_time:
        var t = elapsed - zigzag_start_time
        zigzag = perpendicular * sin(t * waves * PI * 2) * amplitude

    var target_position = start_position + forward + zigzag
    player.velocity = (target_position - player.global_position) / delta

    if elapsed >= dash_time:
        isActive = false
        player.velocity = Vector2.ZERO
        player._finish_ulti_recovery()
