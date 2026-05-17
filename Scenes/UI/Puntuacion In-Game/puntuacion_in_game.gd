extends Node


@onready var scoreboard_panel = $"."
@onready var final_score: Label = $Label/Final_Score
func _ready() -> void:
	SignalManager.gameOver.connect(gameOver)
	if scoreboard_panel:
		scoreboard_panel.visible = false
	

func _unhandled_input(event):
	if event.is_action_pressed("Scoreboard"):
		scoreboard_panel.visible = !scoreboard_panel.visible
	if event.is_action_released("Scoreboard"):
		scoreboard_panel.visible = false

func gameOver()->void:
	final_score.text = "%d"%[GameManager.score]
	scoreboard_panel.visible = true


func _on_button_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/UI/character_select.tscn")
	


func _on_button_2_pressed() -> void:
	get_tree().paused = false
	GameManager.score=0
	#GameManager.percentage_ult = 0
	get_tree().reload_current_scene()
