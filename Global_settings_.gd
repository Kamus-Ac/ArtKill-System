extends Node

signal fps_displayed(value)
signal brightness_updated(value)

# --- VIDEO ---

# 1. MODO DE PANTALLA (Adaptado para tu OptionButton)
func change_displayMode(index: int) -> void:
	match index:
		0: # Full Screen
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
		1: # Windowed
			DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)

# 2. V-SYNC (Conectado a un CheckButton/Toggle)
func change_vsync(toggle: bool) -> void:
	if toggle:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)

# 3. MOSTRAR FPS (Conectado a un CheckButton/Toggle)
func toggle_fps_display(toggle: bool) -> void:
	# En Godot 4, emitir señales es mucho más directo
	fps_displayed.emit(toggle)

# 4. LÍMITE DE FPS (Conectado a tu Slider de Max FPS)
func set_max_fps(value: float) -> void:
	# Convertimos a int por seguridad. Si es mayor al límite de tu slider, 0 significa "sin límite"
	Engine.max_fps = int(value) if value < 500 else 0

# 5. BRILLO (Conectado a tu Slider de Brightness)
func update_brightness(value: float) -> void:
	brightness_updated.emit(value)
