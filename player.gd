extends CharacterBody3D


const SPEED = 10
const JUMP_VELOCITY = 4.5
var angspeed=10
var mouse_sens := 0.25


@onready var cross: MeshInstance3D= %arm/MeshInstance3D
@onready var cam: Node3D= %arm
@onready var gun_anim =$arm/pistol/AnimationPlayer

var _camera_input_direction := Vector2.ZERO

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("leftclick"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
		
func _unhandled_input(event: InputEvent) -> void:
	var is_camera_motion :=(
		event is InputEventMouseMotion and
		Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED
	)
	if is_camera_motion:
		_camera_input_direction = event.screen_relative * mouse_sens
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (cam.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	
	cam.rotation.x -= _camera_input_direction.y*delta
	cam.rotation.x= clamp(cam.rotation.x, -PI / 3, PI/2)
	cam.rotation.y -= _camera_input_direction.x*delta

	_camera_input_direction = Vector2.ZERO
	
	if Input.is_action_just_pressed('leftclick'):
		gun_anim.play("shoot")
