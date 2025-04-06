extends RigidBody3D

@export var damage: int = 20
@export var lifetime: float = 2.0
@onready var hitbox: Area3D = $Hitbox

func _ready():
	# Enable area detection
	hitbox.monitoring = true
	hitbox.monitorable = true

	# Connect to area collisions (will detect enemy hitboxes)
	hitbox.connect("area_entered", Callable(self, "_on_area_entered"))

	# Timer to destroy projectile after its lifetime
	await get_tree().create_timer(lifetime).timeout
	queue_free()

func _on_area_entered(area: Area3D):
	var parent = area.get_parent()
	if parent.is_in_group("enemies"):
		print("Projectile hit enemy:", parent.name)
		if parent.has_method("take_damage"):
			parent.take_damage(damage)
		queue_free()

func get_damage():
	return damage
