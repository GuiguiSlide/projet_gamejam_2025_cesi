extends RigidBody3D  # Use RigidBody3D for proper physics interactions

@export var speed = 20.0  # Speed of the projectile
@export var damage = 10.0  # Damage the projectile deals

@onready var collision_shape = $CollisionShape3D  # Reference to the collision shape
var direction = Vector3.ZERO  # Direction the projectile is moving in

func _ready():
	# Set the projectile's collision layer to a unique value (e.g., layer 2)
	self.collision_layer = 2
	self.collision_mask = 1  # Set the mask to ignore the player's collision layer (layer 1)

	# The direction of the projectile will be set from the player (camera's forward vector)
	set_as_top_level(true)  # Ensure the projectile is updated independently of its parent

	# Apply initial velocity to the projectile in the direction it's facing
	linear_velocity = direction * speed  # Set the initial velocity

func _on_body_entered(body):
	# Check if the projectile collides with an enemy or any other object
	if body.is_in_group("enemy"):  # Assuming your enemies are in the "enemy" group
		body.take_damage(damage)  # Call the enemy's take_damage function to apply damage
		queue_free()  # Destroy the projectile upon collision
	elif body.is_in_group("projectile"):  # If it collides with another projectile, for example
		queue_free()  # Destroy the projectile on collision
