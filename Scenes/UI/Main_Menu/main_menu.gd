extends Control

# Referencias a tus botones dentro del VBoxContainer
@onready var jugar: Button = $VBoxContainer/Jugar
@onready var ajustes: Button = $VBoxContainer/Ajustes
@onready var salir: Button = $VBoxContainer/Salir

func _ready() -> void:
	#Aseguramos que el ratón sea visible
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# Intentamos dar el foco al arrancar
	if jugar:
		jugar.grab_focus()

func _on_ajustes_pressed() -> void:
	pass # Aquí irá tu lógica de ajustes


func _on_jugar_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/UI/character_select.tscn")


func _on_salir_pressed() -> void:
	get_tree().quit()
