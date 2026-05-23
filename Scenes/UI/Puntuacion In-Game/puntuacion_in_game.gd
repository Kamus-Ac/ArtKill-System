extends Node

@onready var ult_score: Label = $Label2/Ult_Score
@onready var time_score: Label = $Label3/Time_Score
@onready var scoreboard_panel = $"."
@onready var final_score: Label = $Label/Final_Score



func _process(_delta: float) -> void:
	if scoreboard_panel.visible:
		check()


func _ready() -> void:
	if scoreboard_panel:
		scoreboard_panel.visible = false
	

func _unhandled_input(event):
	if event.is_action_pressed("Scoreboard"):
		check()
		#scoreboard_panel.visible = !scoreboard_panel.visible
	if event.is_action_released("Scoreboard"):
		scoreboard_panel.visible = false


func check()->void:
	final_score.text = "%d"%[GameManager.score]
	time_score.text = GameManager.get_tiempo()
	ult_score.text = "%d"%[GameManager.ult_tries]

	scoreboard_panel.visible = true
