extends Control

@onready var characters_box: HBoxContainer = $MainPanel/VBox/CharactersBox
@onready var confirm: Button = $MainPanel/VBox/Confirm

var selected_card: PanelContainer = null

func _ready():
	confirm.disabled = true
	for card in characters_box.get_children():
		if card.has_method("set_selected"):
			card.selected.connect(_on_card_selected)
			card.set_selected(false)




func _on_card_selected(card):
	selected_card = card
	for c in characters_box.get_children():
		if c.has_method("set_selected"):
			c.set_selected(c == card)

	confirm.disabled = false

	print("Selected:", card.character_data.character_name)

func _on_confirm_pressed():
	if selected_card == null:
		return

	GameManager.selected_character = selected_card.character_data
	print("Guardado en GameManager:", GameManager.selected_character.character_name)
	get_tree().change_scene_to_file("res://Scenes/Levels/level_base.tscn")
