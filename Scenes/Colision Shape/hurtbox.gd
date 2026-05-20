class_name Player_Hurtbox
extends Area2D

signal received_damage(damage: int, from_position: Vector2)

@export var health: Player_Health

var invulnerable := false


func _ready() -> void:

	area_entered.connect(_on_area_entered)

	monitorable = false
	collision_layer = 0
	collision_mask = 2


func _on_area_entered(hitbox: Area2D) -> void:

	# si es invulnerable, ignora el golpe
	if invulnerable:
		return

	if hitbox != null and hitbox is Enemy_Hitbox:

		invulnerable = true

		health.apply_damage(hitbox.damage)

		received_damage.emit(
			hitbox.damage,
			hitbox.global_position
		)

		print("INVULNERABLE")

		await get_tree().create_timer(3.0).timeout

		invulnerable = false

		print("YA PUEDE RECIBIR DAÑO")
