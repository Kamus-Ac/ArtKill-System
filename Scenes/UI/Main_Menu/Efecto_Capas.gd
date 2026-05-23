extends Sprite2D

@export var divisor_movimiento: float = 6.0 
@export var limite_pixeles: float = 100.0 # El máximo absoluto de píxeles que se moverá la capa más rápida
@export var sensibilidad_joystick: float = 2.0

var posicion_base: Vector2
var input_virtual: Vector2 = Vector2.ZERO
var suavidad: float = 5.0

func _ready():
	posicion_base = position 

func _process(delta):
	var joystick_dir = Vector2(
		Input.get_joy_axis(0, JOY_AXIS_RIGHT_X),
		Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)
	)

	var centro_pantalla = get_viewport_rect().size / 2.0

	if joystick_dir.length() > 0.2:
		input_virtual += joystick_dir * sensibilidad_joystick * delta
		input_virtual.x = clamp(input_virtual.x, -1.0, 1.0)
		input_virtual.y = clamp(input_virtual.y, -1.0, 1.0)
	else:
		var mouse_pos = get_global_mouse_position()
		
		var offset_mouse = (mouse_pos - centro_pantalla) / centro_pantalla
		offset_mouse.x = clamp(offset_mouse.x, -1.0, 1.0)
		offset_mouse.y = clamp(offset_mouse.y, -1.0, 1.0)

		input_virtual = input_virtual.lerp(offset_mouse, suavidad * delta)

	var desplazamiento_final = input_virtual * (limite_pixeles / divisor_movimiento)

	position = position.lerp(posicion_base + desplazamiento_final, suavidad * delta)
