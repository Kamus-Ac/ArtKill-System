extends Control

# Referencias a tus botones dentro del VBoxContainer
@onready var jugar: Button = $VBoxContainer2/JUGAR
@onready var salir: Button = $VBoxContainer2/SALIR
@onready var menu_music = $MenuMusic

var save_scores:ScoresSaved

func _ready() -> void:
	#Aseguramos que el ratón sea visible
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# Intentamos dar el foco al arrancar
	if jugar:
		jugar.grab_focus()
		
	menu_music.play()


func _on_jugar_pressed() -> void:
	menu_music.stop()
	get_tree().change_scene_to_file("res://Scenes/UI/character_select.tscn")


func _on_salir_pressed() -> void:
	get_tree().quit()
