extends Node3D

@export var mob_scenes : Array
var spawn_position = Vector3(-8.076, 1, -5)
var spawn_rotation = Vector3(0, 0, 0)

func _ready():
	# Ensure the mob_scenes array is populated with the paths to your mob scenes
	if mob_scenes.is_empty():
		mob_scenes = [
			preload("res://clownfish.tscn"),
			preload("res://orc.tscn"),
			preload("res://salmon.tscn"),
			preload("res://shark.tscn"),
			preload("res://sunfish.tscn"),
			preload("res://whale.tscn")
		]
	# Start the timer
	var timer = Timer.new()
	timer.wait_time = 5  # Set the timer to 10 seconds
	timer.one_shot = false  # Make the timer repeat
	add_child(timer)  # Add the timer to the scene tree
	timer.start()  # Start the timer
	timer.timeout.connect(Callable(self, "_on_timer_timeout"))

func _on_timer_timeout():
	duplicate_child()

func duplicate_child():
	if mob_scenes.size() > 0:
		# Pick a random mob scene
		var random_index = randi() % mob_scenes.size()
		var mob_scene = mob_scenes[random_index]
		# Instance the mob scene
		var new_child = mob_scene.instantiate()
		# Add the new child to the scene tree (this will automatically assign an owner)
		add_child(new_child)
		# Set the position of the new child
		new_child.global_transform.origin = spawn_position
		# Set the rotation of the new child to the specified spawn rotation
		new_child.rotation_degrees = spawn_rotation
	else:
		push_error("No mob scenes assigned.")
