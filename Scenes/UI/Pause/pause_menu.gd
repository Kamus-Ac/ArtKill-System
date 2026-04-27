extends Control

@onready var level_base = $"../../.."

func _on_menu_principal_pressed() -> void:
	get_tree().quit()
	
func _on_resumen_pressed() -> void:
	level_base.pauseMenu()
