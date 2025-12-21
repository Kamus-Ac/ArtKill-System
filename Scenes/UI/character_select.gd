extends Control

@onready var characters_box: HBoxContainer = $MainPanel/VBox/CharactersBox

var selected_card: PanelContainer = null
var selected_character_id: String = ""


func _ready():
	for card in characters_box.get_children():
		if card.has_method("set_selected"):
			card.selected.connect(_on_card_selected)
			card.set_selected(false)


func _on_card_selected(card):
	selected_card = card
	selected_character_id = card.character_id

	for c in characters_box.get_children():
		if c.has_method("set_selected"):
			c.set_selected(c == card)

	print("Selected character:", selected_character_id)
