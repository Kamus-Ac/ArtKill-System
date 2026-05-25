extends Control

# Referencias a tus botones dentro del VBoxContainer
@onready var jugar: Button = $VBoxContainer2/JUGAR
@onready var salir: Button = $VBoxContainer2/SALIR
@onready var menu_music = $MenuMusic
@onready var glitch = $Glitch

var save_scores:ScoresSaved

func _ready() -> void:
	#Aseguramos que el ratón sea visible
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	# Intentamos dar el foco al arrancar
	if jugar:
		jugar.grab_focus()
		
	menu_music.play()


func _on_jugar_pressed() -> void:
	menu_music.stop()
	glitch.play(.28)
	# 1. Deshabilitamos el botón para evitar que el jugador lo presione múltiples veces
	jugar.disabled = true
	
	 # 2. Obtenemos el material del botón (donde pusimos el shader)
	var material_boton = jugar.material as ShaderMaterial
	
	if material_boton:
		# 3. Creamos un Tween para animar la propiedad 'glitch_intensity' del shader
		var tween = create_tween()
			
		# Hacemos que la intensidad vaya de 0.0 a 1.0 en 0.5 segundos.
		# Puedes ajustar el tiempo (0.5) a tu gusto.
		tween.tween_property(material_boton, "shader_parameter/glitch_intensity", .444, 2.10).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
		
		# 4. Esperamos a que termine la animación del glitch
		await tween.finished
	get_tree().change_scene_to_file("res://Scenes/UI/character_select.tscn")


func _on_salir_pressed() -> void:
	menu_music.stop()
	
	# 1. Deshabilitamos el botón para evitar que el jugador lo presione múltiples veces
	salir.disabled = true
	glitch.play(.28)
	 # 2. Obtenemos el material del botón (donde pusimos el shader)
	var material_boton = salir.material as ShaderMaterial
	
	if material_boton:
		# 3. Creamos un Tween para animar la propiedad 'glitch_intensity' del shader
		var tween = create_tween()
			
		# Hacemos que la intensidad vaya de 0.0 a 1.0 en 0.5 segundos.
		# Puedes ajustar el tiempo (0.5) a tu gusto.
		tween.tween_property(material_boton, "shader_parameter/glitch_intensity", .444, 2.10).set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_IN)
		
		# 4. Esperamos a que termine la animación del glitch
		await tween.finished
	get_tree().quit()
