extends Node3D

@onready var body = $StaticBody3D
@onready var collision_shape = $StaticBody3D/CollisionShape3D  # Make sure the path is correct for your CollisionShape3D node.
var speed = 2.0  # Units per second

# Define health
var health = 100.0  # Initial health of the enemy

# Define the instruction list for pathing
var instructions = [
	{ "type": "move", "distance": 4 },
	{ "type": "turn", "angle": -90 },
	{ "type": "move", "distance": 10 },
	{ "type": "turn", "angle": 90 },
	{ "type": "move", "distance": 6 },
]

var current_instruction = 0
var distance_moved = 0.0

# When an enemy takes damage, reduce health and check if it should die
func take_damage(amount):
	health -= amount
	if health <= 0:
		die()  # Call die function when health reaches 0

# Handle the enemy's death (e.g., destroy the node or play a death animation)
func die():
	queue_free()  # Destroys the enemy node, you could also play an animation here

# Detecting collision with projectiles (if you use Area3D for collision detection)
func _on_Projectile_body_entered(body):
	# Check if the projectile hits the enemy (you can also check projectile tags or types)
	if body.is_in_group("projectile"):  # Assuming you have added the projectile to a group
		take_damage(10.0)  # Apply damage to the enemy
		body.queue_free()  # Destroy the projectile upon collision

# This is the normal movement and path following logic
func _physics_process(delta):
	if current_instruction >= instructions.size():
		return  # All instructions done

	var instr = instructions[current_instruction]

	if instr.type == "move":
		var move_distance = speed * delta
		var remaining = instr.distance - distance_moved
		var actual_move = min(move_distance, remaining)

		# Move forward in local Z direction
		translate(Vector3.FORWARD * actual_move)
		distance_moved += actual_move

		if distance_moved >= instr.distance:
			current_instruction += 1
			distance_moved = 0.0

	elif instr.type == "turn":
		# Turn in place (instant for now)
		rotate_y(deg_to_rad(instr.angle))
		current_instruction += 1
