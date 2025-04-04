extends CharacterBody3D

const SPEED = 10.0
const JUMP_VELOCITY = 4.5
const MOUSE_SENS = 0.25

# Node References
@onready var cam: Node3D = $arm
@onready var gun_anim: AnimationPlayer = $arm/pistol/AnimationPlayer

# Gravity as a scalar (float)
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")  # Directly get gravity value

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _input(event: InputEvent):
	if event.is_action_pressed("leftclick"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event.is_action_pressed("ui_accept"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _unhandled_input(event: InputEvent):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		cam.rotation.x -= deg_to_rad(event.relative.y * MOUSE_SENS)
		cam.rotation.x = clamp(cam.rotation.x, deg_to_rad(-90), deg_to_rad(90))
		rotate_y(deg_to_rad(-event.relative.x * MOUSE_SENS))

func _physics_process(delta):
	# Apply gravity (as a float to velocity.y)
	if not is_on_floor():
		velocity.y -= gravity * delta  # Now uses scalar gravity

	# Jumping
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Movement
	var input_dir = Input.get_vector("left", "right", "foward", "backward")
	var direction = (cam.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

	# Shooting
	if Input.is_action_just_pressed("leftclick") and gun_anim:
		gun_anim.play("shoot")
