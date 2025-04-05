extends RigidBody3D

@export var damage: int = 20
@export var lifetime: float = 2.0

func _ready():
	collision_layer = 2  # Projectile layer
	collision_mask = 3   # Collide with enemies (layer 3)
	# Connect the collision signal to detect body entry
	connect("body_entered", Callable(self, "_on_body_entered"))
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _on_body_entered(body: Node):
	if body.is_in_group("enemies"):
		body.take_damage(damage)
		queue_free()
