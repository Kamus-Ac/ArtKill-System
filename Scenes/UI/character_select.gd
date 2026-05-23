extends Control

@onready var characters_box: HBoxContainer = $MainPanel/VBox/CharactersBox
@onready var gus: PanelContainer = $MainPanel/VBox/CharactersBox/Gus
@onready var tomy: PanelContainer = $MainPanel/VBox/CharactersBox/Tomy
@onready var dani: PanelContainer = $MainPanel/VBox/CharactersBox/Dani
@onready var confirm: TextureButton = $MainPanel/VBox/HBoxContainer/CONFIRMAR
@onready var volver: TextureButton = $MainPanel/VBox/HBoxContainer/VOLVER
@onready var character_music = $CharacterMusic

var selected_card: PanelContainer = null

func _ready():
	character_music.play()
	confirm.disabled = true
	for card in characters_box.get_children():
		if card.has_method("set_selected"):
			card.selected.connect(_on_card_selected)
			card.set_selected(false)
			
		card.focus_mode = Control.FOCUS_ALL
		card.gui_input.connect(_on_card_gui_input.bind(card))
		card.focus_entered.connect(_on_card_focus_entered.bind(card))
		card.focus_exited.connect(_on_card_focus_exited.bind(card))
		card.pivot_offset = card.size / 2.0

	if gus:
		gus.grab_focus()

func _on_card_focus_entered(card: PanelContainer) -> void:
	var tween = create_tween()
	tween.tween_property(card, "modulate", Color(1.2, 1.2, 1.2), 0.15)
	tween.parallel().tween_property(card, "scale", Vector2(1.05, 1.05), 0.15)


func _on_card_focus_exited(card: PanelContainer) -> void:
	var tween = create_tween()
	tween.tween_property(card, "modulate", Color(1.0, 1.0, 1.0), 0.15)
	tween.parallel().tween_property(card, "scale", Vector2(1.0, 1.0), 0.15)


func _on_card_gui_input(event: InputEvent, card: PanelContainer) -> void:
	if card.has_focus() and event.is_action_pressed("ui_accept"):
		_on_card_selected(card)


func _on_card_selected(card):
	selected_card = card
	for c in characters_box.get_children():
		if c.has_method("set_selected"):
			c.set_selected(c == card)

	confirm.disabled = false
	print("Selected:", card.character_data.character_name)

	GameManager.selected_character = selected_card.character_data
	print("Guardado en GameManager:", GameManager.selected_character.character_name)


func _on_confirmar_pressed() -> void:
	if selected_card == null:
		return
	character_music.stop()
	get_tree().change_scene_to_file("res://Scenes/assets/loadscene/scene/LoadScene.tscn")


func _on_volver_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/UI/Main_Menu/main_menu.tscn")
