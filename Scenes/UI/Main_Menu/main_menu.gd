extends Control

# Las rutas están perfectas, coinciden con tu VBoxContainer
@onready var yugar: TextureButton = $Fondo/VBoxContainer/YUGAR
@onready var ajustes: TextureButton = $Fondo/VBoxContainer/AJUSTES
@onready var zalir: TextureButton = $Fondo/VBoxContainer/ZALIR

func _ready() -> void:
	# 1. Aseguramos que el ratón sea visible
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# 2. EL ARREGLO ESTÁ AQUÍ:
	# Tienes que decirle a Godot *quién* recibe el foco. 
	# Al poner "yugar.grab_focus()", el mando ya sabe dónde empezar.
	if yugar:
		yugar.grab_focus()

func _process(_delta: float) -> void:
	pass

func _on_yugar_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/UI/character_select.tscn")

func _on_zalir_pressed() -> void:
	get_tree().quit()

func _on_ajustes_pressed() -> void:
	pass # Replace with function body.
