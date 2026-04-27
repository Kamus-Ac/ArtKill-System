extends Control

@onready var level_base = $"../../.."

func _on_menu_principal_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/UI/Main_Menu/main_menu.tscn")
	
func _on_resumen_pressed() -> void:
	level_base.pauseMenu()
