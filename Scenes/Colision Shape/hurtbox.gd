class_name Player_Hurtbox
extends Area2D

signal received_damage(damage: int, from_position: Vector2)

@export var health: Player_Health

@onready var player = get_tree().get_first_node_in_group("player")


func _ready() -> void:
	area_entered.connect(_on_area_entered)

	monitorable = false
	collision_layer = 0
	collision_mask = 2


func _on_area_entered(hitbox: Area2D) -> void:

	# si es invulnerable, ignora el golpe
	if player.isInvulnerable or health.invulnerable:
		return

	if hitbox != null and hitbox is Enemy_Hitbox:

		health.apply_damage(hitbox.damage)
		health.set_temporary_invulnerable(3.0)
		received_damage.emit(
			hitbox.damage,
			hitbox.global_position
		)
