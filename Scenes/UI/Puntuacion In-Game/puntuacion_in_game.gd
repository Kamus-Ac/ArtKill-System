extends Node


@onready var scoreboard_panel = $"."

func _ready() -> void:
	if scoreboard_panel:
		scoreboard_panel.visible = false
	

func _unhandled_input(event):
	if event.is_action_pressed("Scoreboard"):
		scoreboard_panel.visible = !scoreboard_panel.visible
	if event.is_action_released("Scoreboard"):
		scoreboard_panel.visible = false
