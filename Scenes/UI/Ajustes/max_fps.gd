extends Label

func _ready() -> void:
	# Sintaxis de Godot 4 para conectar señales por código
	GlobalSettings.fps_displayed.connect(_on_fps_displayed)

func _process(delta: float) -> void:
	text = "%s" % [Engine.get_frames_per_second()]

func _on_fps_displayed(value: bool) -> void:
	visible = value
