extends Control

# Referencias a tus botones dentro del VBoxContainer
@onready var jugar: Button = $VBoxContainer2/JUGAR
@onready var ajustes: Button = $VBoxContainer2/AJUSTES
@onready var salir: Button = $VBoxContainer2/SALIR

var save_scores:ScoresSaved

func _ready() -> void:
	#Aseguramos que el ratón sea visible
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	ScoresSaved.load_savegame()
	# Intentamos dar el foco al arrancar
	if jugar:
		jugar.grab_focus()

func _on_ajustes_pressed() -> void:
	pass # Aquí irá tu lógica de ajustes


func _on_jugar_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/UI/character_select.tscn")


func _on_salir_pressed() -> void:
	get_tree().quit()
