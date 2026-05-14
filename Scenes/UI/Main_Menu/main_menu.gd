extends Control

# Referencias a tus botones dentro del VBoxContainer
@onready var yugar: TextureButton = $Fondo/VBoxContainer/YUGAR
@onready var ajustes: TextureButton = $Fondo/VBoxContainer/AJUSTES
@onready var zalir: TextureButton = $Fondo/VBoxContainer/ZALIR

func _ready() -> void:
	#Aseguramos que el ratón sea visible
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# Intentamos dar el foco al arrancar
	if yugar:
		yugar.grab_focus()

func _on_yugar_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/UI/character_select.tscn")

func _on_zalir_pressed() -> void:
	get_tree().quit()

func _on_ajustes_pressed() -> void:
	pass # Aquí irá tu lógica de ajustes
