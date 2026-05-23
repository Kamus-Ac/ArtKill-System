extends Node

@onready var nombre: LineEdit = $PanelContainer/MarginContainer/VBoxContainer/Nombre
@onready var ult_score: Label = $Label2/Ult_Score
@onready var time_score: Label = $Label3/Time_Score
@onready var scoreboard_panel = $"."
@onready var final_score: Label = $Label/Final_Score
@export var score_save:ScoresSaved

var best_score: int
var current_score:int
var current_name: String
var current_position: int
func _ready() -> void:
	if ScoresSaved.save_exists():
		score_save = ScoresSaved.load_savegame()
	SignalManager.gameOver.connect(gameOver)
	if scoreboard_panel:
		scoreboard_panel.visible = false
	

func _unhandled_input(event):
	if event.is_action_pressed("Scoreboard"):
		check()
		#scoreboard_panel.visible = !scoreboard_panel.visible
	if event.is_action_released("Scoreboard"):
		scoreboard_panel.visible = false

func gameOver()->void:
	final_score.text = "%d"%[GameManager.score]
	time_score.text = "%d"%[GameManager.playtime]
	ult_score.text = "%d"%[GameManager.ult_tries]
	scoreboard_panel.visible = true
	nombre.visible = true

func check()->void:
	final_score.text = "%d"%[GameManager.score]
	time_score.text = "%d"%[GameManager.playtime]
	ult_score.text = "%d"%[GameManager.ult_tries]

	scoreboard_panel.visible = true


func _on_button_pressed() -> void:
	get_tree().paused = false
	score_save_file2()
	score_save.write_savegame()
	get_tree().change_scene_to_file("res://Scenes/ScoreScene/score_scene.tscn")
	


func _on_button_2_pressed() -> void:
	get_tree().paused = false
	#GameManager.percentage_ult = 0
	get_tree().reload_current_scene()

func score_save_file()->void:
	print(score_save)
	current_position = -1
	for i in range(score_save.scores.size()):
		if GameManager.score>score_save.scores[i]:
			current_position = i
			break
	if current_position == -1:
		return
	for i in range(score_save.scores.size()-1, current_position, -1):
		score_save.scores[i] = score_save.scores[i-1]
		score_save.names[i] = score_save.names[i-1]
	score_save.scores[current_position] = int(GameManager.score)
	score_save.names[current_position] = nombre.text

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

	print(score_save.scores)
	print(score_save.names)
	print(ScoresSaved.get_save_path())
		
