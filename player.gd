extends CharacterBody3D

const SPEED = 10.0
const JUMP_VELOCITY = 4.5
const MOUSE_SENS = 0.25
const PROJECTILE_SCENE = preload("res://projectile.tscn")
@export var shootsound : AudioStream = preload("res://sons/fast_shot.mp3")
@export var main_menu : AudioStream = preload("res://sons/aquatower_song.mp3")
@export var towerplace : AudioStream = preload("res://sons/tour_placement.mp3")
@export var tower_scenes : Array = []  # Array for tower scenes
const SHOOT_COOLDOWN = 0.3  # seconds between shots
var can_scroll: bool = true
var scroll_cooldown_timer: Timer
const SCROLL_COOLDOWN = 1.0
# Create scroll cooldown timer



@onready var animpistol = $arm/Camera3D/pistol/AnimationPlayer
@onready var cam: Camera3D = $arm/Camera3D
@onready var pistol: Node3D = $arm/Camera3D/pistol
@onready var wrench: Node3D = $arm/Camera3D/wrench
@onready var blue_filter: ColorRect = $arm/Camera3D/ColorRect
@onready var health_label: Label = $arm/Camera3D/ui/health
@onready var money_label: Label = $arm/Camera3D/ui/money

var player_money: int = 100
var player_health: int = 100
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var current_weapon = "pistol"
var can_shoot = true
var shoot_timer: Timer
var current_tower_index = 0  # Tracks the selected tower index
var main_music = load("res://sons/aquatower_song.mp3")

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	blue_filter.mouse_filter = Control.MOUSE_FILTER_IGNORE
	update_weapon()

	# Initialize UI
	money_label.text = "Coins: " + str(player_money)
	health_label.text = "Health: " + str(player_health)

	# Create and configure shoot cooldown timer if it doesn't exist
	if not shoot_timer:
		shoot_timer = Timer.new()
		shoot_timer.wait_time = SHOOT_COOLDOWN
		shoot_timer.one_shot = true
		shoot_timer.connect("timeout", Callable(self, "_on_shoot_cooldown_timeout"))
		add_child(shoot_timer)

	# Ensure the tower_scenes array is populated in the editor if empty
	if tower_scenes.is_empty():
		tower_scenes = [
			preload("res://sharktower.tscn"),
			preload("res://eeltower.tscn"),
			preload("res://puffertower.tscn"),
			preload("res://sharktower.tscn"),
			preload("res://squidtower.tscn"),
		]

	# Play the background music
	var main_music_player = AudioStreamPlayer.new()
	add_child(main_music_player)
	main_music_player.stream = main_menu
	main_music_player.play()
	main_music_player.volume_db = -30.0 # Ajustez cette valeur pour contrôler le 


func _input(event):
	if event.is_action_pressed("leftclick"):
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

	# Allow tower switching when the wrench is in hand
	if current_weapon == "wrench":
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_WHEEL_UP:
			# Cycle through towers on scroll up (go backwards)
			current_tower_index = (current_tower_index - 1 + tower_scenes.size()) % tower_scenes.size()
			print("Selected tower index: ", current_tower_index)
		elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			# Cycle through towers on scroll down (go forwards)
			current_tower_index = (current_tower_index + 1) % tower_scenes.size()
			print("Selected tower index: ", current_tower_index)

func _unhandled_input(event):
	if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		var delta = event.relative * MOUSE_SENS
		cam.rotation.x -= deg_to_rad(delta.y)
		cam.rotation.x = clamp(cam.rotation.x, deg_to_rad(-90), deg_to_rad(90))
		rotate_y(deg_to_rad(-delta.x))

	if event.is_action_pressed("weapon1"):
		switch_weapon("pistol")
	if event.is_action_pressed("weapon2"):
		switch_weapon("wrench")

func _physics_process(delta):
	if position.y <= -100:
		position.y = 100

	# Update UI labels
	health_label.text = "Health: " + str(player_health)
	money_label.text = "Coins: " + str(player_money)

	if not is_on_floor():
		velocity.y -= gravity * delta

	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	var input_dir = Input.get_vector("left", "right", "forward", "backward")
	var direction = (cam.global_transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()

	if Input.is_action_just_pressed("leftclick"):
		if current_weapon == "pistol":
			var shoot_music_player = AudioStreamPlayer.new()
			add_child(shoot_music_player)
			shoot_music_player.stream = shootsound
			shoot_music_player.play() 
			if can_shoot:
				can_shoot = false
				animpistol.play("shoot")
# Play the shooting sound
				shoot_projectile()
				shoot_timer.start()
		elif current_weapon == "wrench":
			place_tower()

func _on_shoot_cooldown_timeout():
	can_shoot = true

func switch_weapon(new_weapon: String):
	current_weapon = new_weapon
	update_weapon()

func update_weapon():
	if pistol:
		pistol.visible = (current_weapon == "pistol")
	if wrench:
		wrench.visible = (current_weapon == "wrench")
	if blue_filter:
		blue_filter.visible = (current_weapon == "wrench")

func take_damage(amount: int):
	player_health -= amount
	health_label.text = "Health: " + str(player_health)

	if player_health <= 0:
		get_tree().reload_current_scene()

func die():
	get_tree().reload_current_scene()

func add_money(amount: int):
	player_money += amount
	money_label.text = "Coins: " + str(player_money)

func shoot_projectile():
	if not pistol:
		print("Pistol node is missing!")
		return

	var projectile = PROJECTILE_SCENE.instantiate()
	get_tree().current_scene.add_child(projectile)

	if not projectile.is_inside_tree():
		print("Projectile is not inside the tree after adding it!")
		return

	var spawn_pos = pistol.global_position + (-pistol.global_transform.basis.z * 0.5)
	var cam_forward = -cam.global_transform.basis.z.normalized()
	projectile.global_transform.origin = spawn_pos

	projectile.look_at(projectile.global_transform.origin + cam_forward, Vector3.UP)

	projectile.linear_velocity = cam_forward * 50


func place_tower():
	if wrench:
		if player_money >= 25:
			player_money -= 25
			money_label.text = "Coins: " + str(player_money)
			var tower_music_player = AudioStreamPlayer.new()
			add_child(tower_music_player)
			tower_music_player.stream = towerplace
			tower_music_player.play() # Play the shooting sound

			var tower = tower_scenes[current_tower_index].instantiate()
			get_tree().current_scene.add_child(tower)

			if not tower.is_inside_tree():
				print("Tower placement failed!")
				return

			var ray_origin = cam.global_position
			var ray_direction = -cam.global_transform.basis.z.normalized()
			var space_state = get_world_3d().direct_space_state
			var query = PhysicsRayQueryParameters3D.create(
				ray_origin,
				ray_origin + ray_direction * 10
			)
			query.exclude = [self]

			var ray_result = space_state.intersect_ray(query)
			if ray_result:
				tower.global_transform.origin = ray_result.position
			else:
				print("Invalid tower placement!")
				tower.queue_free()
				player_money += 10
				money_label.text = "Coins: " + str(player_money)
	else:
		print("Wrench node is missing!")
