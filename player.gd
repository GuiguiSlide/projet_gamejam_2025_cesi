extends CharacterBody3D

const SPEED = 10.0
const JUMP_VELOCITY = 4.5
const MOUSE_SENS = 0.25
const PROJECTILE_SCENE = preload("res://projectile.tscn") # Update with your actual projectile scene path

@onready var cam: Node3D = $arm  # Camera node
@onready var gun_anim: AnimationPlayer = $arm/pistol/AnimationPlayer
@onready var pistol: Node3D = $arm/pistol  # The pistol node (where the projectile will spawn)

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if pistol:
		print("Pistol node found:", pistol.name)
	else:
		print("Pistol node NOT found!")

func _input(event: InputEvent):
	if event.is_action_pressed("leftclick"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _unhandled_input(event: InputEvent):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		cam.rotation.x -= deg_to_rad(event.relative.y * MOUSE_SENS)
		cam.rotation.x = clamp(cam.rotation.x, deg_to_rad(-90), deg_to_rad(90))
		rotate_y(deg_to_rad(-event.relative.x * MOUSE_SENS))

func _physics_process(delta):
	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir = Input.get_vector("left", "right", "foward", "backward")
	var cam_basis = cam.global_transform.basis
	var forward = cam_basis.z
	var right = cam_basis.x

	# Keep movement on the ground (no vertical component)
	forward.y = 0
	right.y = 0
	forward = forward.normalized()
	right = right.normalized()

	var direction = (right * input_dir.x + forward * input_dir.y).normalized()

	if direction.length() > 0:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

	# Shooting logic
	if Input.is_action_just_pressed("leftclick") and gun_anim:
		# Play shooting animation
		gun_anim.play("shoot") 

		# Create and shoot the projectile
		shoot_projectile()

func shoot_projectile():
	if pistol and pistol.is_inside_tree():  # Ensure pistol is in the scene
		# Create the projectile instance
		var projectile = PROJECTILE_SCENE.instantiate()

		# Position the projectile at the muzzle of the pistol
		projectile.global_transform.origin = pistol.global_transform.origin

		# Add the projectile to the scene
		get_tree().current_scene.add_child(projectile)

		# Apply the projectile movement (using the direction the camera is facing)
		if projectile is MeshInstance3D:  # Ensure it's a MeshInstance3D
			# Calculate the forward direction of the camera
			var cam_basis = cam.global_transform.basis
			var forward = cam_basis.z.normalized()  # Forward direction of the camera

			# Set initial speed and direction of the projectile
			var direction = forward
			projectile.set_script(load("res://scripts/projectile_script.gd"))  # Assuming you add a script for projectile behavior

			# Set rotation of the projectile to match camera orientation
			projectile.rotation_degrees = Vector3(0, -cam.rotation.y, 0)  # Rotate the projectile along Y-axis to face the camera direction

			# Apply movement manually in the next script (projectile_script.gd)
			print("Projectile fired from", pistol.global_transform.origin)
		else:
			print("Projectile is not a MeshInstance3D!")
	else:
		print("Pistol node is missing or not inside the scene tree!")
