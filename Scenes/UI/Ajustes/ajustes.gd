extends Control

@onready var volver: TextureButton = $TextureRect/VOLVER
@onready var pantalla: TabBar = $TextureRect/PanelContainer/TabContainer/PANTALLA
@onready var opdisplay: OptionButton = $TextureRect/PanelContainer/TabContainer/PANTALLA/MarginContainer/GridContainer/OpcionDisplay
@onready var vsync: CheckButton = $TextureRect/PanelContainer/TabContainer/PANTALLA/MarginContainer/GridContainer/vsync
@onready var dsplyfps: CheckButton = $TextureRect/PanelContainer/TabContainer/PANTALLA/MarginContainer/GridContainer/Dsplyfps
@onready var maxfps: HSlider = $TextureRect/PanelContainer/TabContainer/PANTALLA/MarginContainer/GridContainer/Mxfps
@onready var maxbri: HSlider = $TextureRect/PanelContainer/TabContainer/PANTALLA/MarginContainer/GridContainer/mxBri

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if pantalla:
		pantalla.grab_focus()

func _on_volver_pressed() -> void:
	get_tree().change_scene_to_file("res://Scenes/UI/Main_Menu/main_menu.tscn")


func _on_opcion_display_item_selected(index: int) -> void:
	GlobalSettings.change_displayMode(index)

func _on_vsync_toggled(toggled_on: bool) -> void:
	GlobalSettings.change_vsync(toggled_on)


func _on_dsplyfps_toggled(toggled_on: bool) -> void:
	GlobalSettings.toggle_fps_display(toggled_on)

func _on_mxfps_value_changed(value: float) -> void:
	GlobalSettings.set_max_fps(value)

func _on_mx_bri_value_changed(value: float) -> void:
	GlobalSettings.update_brightness(value)


#func _on_master_value_changed(value: float) -> void:
	#pass # Replace with function body.
#
#
#func _on_musica_value_changed(value: float) -> void:
	#pass # Replace with function body.
#
#
#func _on_sfx_value_changed(value: float) -> void:
	#pass # Replace with function body.
