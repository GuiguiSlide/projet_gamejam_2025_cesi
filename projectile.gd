extends RigidBody3D

@export var damage := 20
@export var lifetime := 2.0

func _ready():
	collision_layer = 2  # Projectile layer
	collision_mask = 3   # Collide with enemies
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _on_body_entered(body):
	if body.is_in_group("enemies"):
		body.take_damage(damage)
	queue_free()
