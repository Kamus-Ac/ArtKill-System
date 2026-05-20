extends Camera2D

var target_position = Vector2.ZERO

func _ready() -> void:
	enabled = true
	make_current()

func _process(_delta: float) -> void:
	acquire_target()
	global_position = global_position.lerp(target_position, 1.0 - exp(-_delta*50))
	"""global_position = Vector2.ZERO
	zoom = Vector2.ONE"""

func acquire_target():
	var player_nodes = get_tree().get_nodes_in_group("player")
	if player_nodes.size() > 0:
		var player = player_nodes[0] as Node2D
		target_position = player.global_position