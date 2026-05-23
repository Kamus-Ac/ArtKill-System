extends Node

@onready var nombre: LineEdit = $ColorRect/Nombre
@onready var ult_score: Label = $"ColorRect/Ultis Usadas/Ultis_Usadas_cont"
@onready var time_score: Label = $"ColorRect/Tiempo Sobrevivido/Tiempo_Sobrevivido_cont"
@onready var GameOver_Panel = $"."
@onready var final_score: Label = $"ColorRect/Puntuacion final/Puntuacion_final_conta"
@export var score_save:ScoresSaved
@onready var boton_reintentar = $ColorRect/Reintentar

var best_score: int
var current_score:int
var current_name: String
var current_position: int

func _ready() -> void:
	if ScoresSaved.save_exists():
		score_save = ScoresSaved.load_savegame()
	GameOver_Panel.visible = false
	SignalManager.gameOver.connect(_mostrar_GameOver_Panel)



func _mostrar_GameOver_Panel() -> void:
	final_score.text = "%d" % [GameManager.score]
	time_score.text = GameManager.get_tiempo()
	ult_score.text = "%d" % [GameManager.ult_tries]
	GameOver_Panel.visible = true
	nombre.visible = true
	boton_reintentar.grab_focus()

func _on_menu_principal_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/UI/Main_Menu/main_menu.tscn")

func _on_scoreboard_pressed() -> void:
	get_tree().paused = false
	score_save_file2()
	score_save.write_savegame()
	get_tree().change_scene_to_file("res://Scenes/ScoreScene/score_scene.tscn")

func _on_reintentar_pressed() -> void:
	get_tree().paused = false
	get_tree().reload_current_scene() 


func score_save_file2() -> void:
	current_position = -1
	for i in range(score_save.scores.size()):
		if GameManager.score >= score_save.scores[i]:
			current_position = i
			break
	
	if current_position == -1:
		return
	
	var new_scores = score_save.scores.duplicate()
	var new_names = score_save.names.duplicate()
	
	for i in range(new_scores.size() - 1, current_position, -1):
		new_scores[i] = new_scores[i - 1]
		new_names[i] = new_names[i - 1]
	
	new_scores[current_position] = GameManager.score
	new_names[current_position] = nombre.text
	
	score_save.scores = new_scores
	score_save.names = new_names
