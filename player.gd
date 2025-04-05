extends CharacterBody3D

const SPEED = 10.0
const JUMP_VELOCITY = 4.5
const MOUSE_SENS = 0.25
const PROJECTILE_SCENE = preload("res://projectile.tscn")
const TOWER_SCENE = preload("res://towertemplate.tscn")

@onready var cam: Camera3D = $arm/Camera3D
@onready var pistol: Node3D = $arm/pistol
@onready var wrench: Node3D = $arm/wrench
@onready var blue_filter = $arm/Camera3D/ColorRect

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var current_weapon = "pistol"

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	update_weapon()

func _input(event):
	# Toggle mouse capture with left click and Escape
	if event.is_action_pressed("leftclick"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _unhandled_input(event):
	# Mouse look only when captured
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		cam.rotation.x -= deg_to_rad(event.relative.y * MOUSE_SENS)
		cam.rotation.x = clamp(cam.rotation.x, deg_to_rad(-90), deg_to_rad(90))
		rotate_y(deg_to_rad(-event.relative.x * MOUSE_SENS))
	
	# Weapon switching
	if event.is_action_pressed("weapon1"):
		switch_weapon("pistol")
	if event.is_action_pressed("weapon2"):
		switch_weapon("wrench")

func _physics_process(delta):
	# Gravity
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Jump
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Movement input
	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (cam.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
	
	# Weapon actions
	if Input.is_action_just_pressed("leftclick"):
		if current_weapon == "pistol":
			shoot_projectile()
		elif current_weapon == "wrench":
			place_tower()

func switch_weapon(new_weapon: String):
	current_weapon = new_weapon
	update_weapon()

func update_weapon():
	pistol.visible = (current_weapon == "pistol")
	wrench.visible = (current_weapon == "wrench")
	blue_filter.visible = (current_weapon == "wrench")

func shoot_projectile():
	var projectile = PROJECTILE_SCENE.instantiate()
	var spawn_pos = pistol.global_position + (-pistol.global_transform.basis.z * 0.5)
	var cam_forward = -cam.global_transform.basis.z.normalized()
	
	projectile.global_transform.origin = spawn_pos
	get_tree().current_scene.add_child(projectile)
	projectile.apply_central_impulse(cam_forward * 50)

func place_tower():
	var tower = TOWER_SCENE.instantiate()
	tower.global_transform = wrench.global_transform
	get_tree().current_scene.add_child(tower)
