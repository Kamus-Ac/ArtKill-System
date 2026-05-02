extends Control

@onready var level_base = $"../../.."

# 1. OBTENEMOS LAS REFERENCIAS A LOS BOTONES
# (Usamos comillas dobles en $"..." para el segundo porque el nodo tiene un espacio en el nombre)
@onready var resumen_btn: TextureButton = $CenterContainer/TextureRect/resumen
@onready var menu_principal_btn: TextureButton = $"CenterContainer/TextureRect/menu principal"

func _ready() -> void:
	# 2. CONECTAR SEÑAL DE VISIBILIDAD
	# Esto es vital porque _ready() solo se ejecuta una vez al cargar el nivel.
	# Necesitamos que agarre el foco cada vez que la pantalla de pausa se muestre.
	visibility_changed.connect(_on_visibility_changed)
		
	# 3. ENLAZAR BOTONES MANUALMENTE (Ya que no hay VBoxContainer)
	if resumen_btn and menu_principal_btn:
		# Desde REANUDAR, si pulsas abajo, vas a MENU PRINCIPAL
		resumen_btn.focus_neighbor_bottom = menu_principal_btn.get_path()
		
		# Desde MENU PRINCIPAL, si pulsas arriba, vas a REANUDAR
		menu_principal_btn.focus_neighbor_top = resumen_btn.get_path()

# 4. FUNCIÓN QUE SE EJECUTA CADA VEZ QUE SE ABRE/CIERRA LA PAUSA
func _on_visibility_changed() -> void:
	# Si el menú se acaba de hacer visible, le damos el foco al botón
	if visible and resumen_btn:
		resumen_btn.grab_focus()

# --- FUNCIONES ORIGINALES ---

func _on_menu_principal_pressed() -> void:
	Engine.time_scale = 1
	get_tree().change_scene_to_file("res://Scenes/UI/Main_Menu/main_menu.tscn")
	
func _on_resumen_pressed() -> void:
	level_base.pauseMenu()
