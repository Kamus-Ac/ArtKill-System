extends SubViewport

func _ready():
	world_2d = get_tree().root.world_2d
	render_target_update_mode = UPDATE_ALWAYS