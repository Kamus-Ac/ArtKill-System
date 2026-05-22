extends Control

@onready var level_base: Node2D = $"../../.."

# 1. Referencias a los botones (usamos $"..." en el segundo por el espacio en el nombre)
@onready var resumen_btn: TextureButton = $CenterContainer/Label/resumen
@onready var menu_principal_btn: TextureButton = $"CenterContainer/Label/menu principal"

func _ready() -> void:
	
	#Raza, y estos comentarios de Claude? 
	#JSJSJSJSJ AY Manuelin pss q te digo, no encontraba el eror, solo era q no
	#Me acordaba q se modifico el como se pone pausa XDDDDD

	# ¡TRUCO A PRUEBA DE FALLOS!
	# Forzamos por código que este menú nunca se congele aunque el juego esté pausado.
	# Así no tienes que buscar la opción en el Inspector y el mando siempre funcionará.
	process_mode = Node.PROCESS_MODE_ALWAYS
		
	#Conectar la señal de visibilidad
	# Avisa cada vez que pones pausa o la quitas.
	visibility_changed.connect(_on_visibility_changed)

# Dar foco cada vez que se abre la pausa
func _on_visibility_changed() -> void:
	if visible and resumen_btn:
		#para que no falle al pausar de golpe
		resumen_btn.call_deferred("grab_focus")

# --- FUNCIONES DE LOS BOTONES ---


func _on_menu_principal_pressed() -> void:
	get_tree().paused = false
	get_tree().change_scene_to_file("res://Scenes/UI/Main_Menu/main_menu.tscn")
	
func _on_resumen_pressed() -> void:
	level_base.pauseMenu()
