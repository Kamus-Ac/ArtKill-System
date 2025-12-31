extends PanelContainer

signal selected(card)

@export var character_data: CharacterData

@onready var sprite: TextureRect = $VBoxContainer/Sprite
@onready var name_label: Label = $VBoxContainer/Name


func _ready():
	name_label.text = character_data.character_name
	sprite.texture = character_data.sprite.get_frame_texture("idle", 0)
	mouse_filter = Control.MOUSE_FILTER_STOP


func _gui_input(event):
	if event is InputEventMouseButton \
	and event.button_index == MOUSE_BUTTON_LEFT \
	and event.pressed:
		emit_signal("selected", self)


func set_selected(value: bool):
	if value:
		modulate = Color(1, 1, 1)
	else:
		modulate = Color(0.6, 0.6, 0.6)
