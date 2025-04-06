# tower_projectile.gd
extends Area3D

@export var speed = 20.0
@export var damage = 15
var direction := Vector3.FORWARD

func _ready():
	# Automatic cleanup after 2 seconds (prevents memory leaks)
	await get_tree().create_timer(2.0).timeout
	queue_free()

func _process(delta):
	global_translate(direction * speed * delta)

func set_direction(new_direction: Vector3):
	direction = new_direction.normalized()

func _on_body_entered(body):
	if body.is_in_group("enemy"):
		# Add your enemy damage logic here
		if body.has_method("take_damage"):
			body.take_damage(damage)
		queue_free()
