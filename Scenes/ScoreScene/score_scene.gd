extends Control

@export var Names:Array[RichTextLabel]
@export var Scores:Array[RichTextLabel]
@export var scoresaved: ScoresSaved

var local_names:Array[String] = []
var local_scores:Array[int] = []

var view: bool = false


func _ready() -> void:
	if ScoresSaved.save_exists():
		scoresaved = ScoresSaved.load_savegame()
	load_scores()
	fill()
	print(scoresaved.scores)
	print(scoresaved.names)


func load_scores() -> void:
	local_names = scoresaved.names.duplicate()
	local_scores = scoresaved.scores.duplicate()


func _process(_delta: float) -> void:
	if !view:
		view = true
		await get_tree().create_timer(3.0).timeout
		fill_without_effects()
	if view:
		if Input.is_action_just_pressed("Pausa"):
			get_tree().change_scene_to_file("res://Scenes/UI/Main_Menu/main_menu.tscn")


func fill():
	for i in range(local_scores.size()):
		Names[i].text = "[matrix][center][font=res://Scenes/UI/Vermin Vibes 1989.ttf][font_size=64]???[/font_size][/font][/center][/matrix]"

		Scores[i].text = "[center][font=res://Scenes/UI/Vermin Vibes 1989.ttf][font_size=64]%s[/font_size][/font][/center]" %local_scores[i]

		


func fill_without_effects():
	for i in range(local_scores.size()):
		Names[i].text = "[center][font=res://Scenes/UI/Vermin Vibes 1989.ttf][font_size=64]%s[/font_size][/font][/center]" %local_names[i]

		Scores[i].text = "[center][font=res://Scenes/UI/Vermin Vibes 1989.ttf][font_size=64]%s[/font_size][/font][/center]" %local_scores[i] 
