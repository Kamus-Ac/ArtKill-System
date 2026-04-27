extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Aseguramos que el ratón sea visible si vienes de un juego en 3D/FPS
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_jugar_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/UI/character_select.tscn")


func _on_salir_pressed() -> void:
	get_tree().quit()


func _on_opciones_pressed() -> void:
	pass # Replace with function body.
