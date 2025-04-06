extends Node3D

@export var mob_scenes : Array
var spawn_position = Vector3(-8.076, 1, -5)
var spawn_rotation = Vector3(0, 0, 0)
var wave1: Array =[0,0,0,0,1,1,1]
var wave2: Array =[0,0,0,0,1,1,1,1,2,2,2,3]
var wave3: Array =[0,0,0,0,1,1,1,1,2,2,2,3,3,3,3,4,4,5]
var curwave=1
var enemywave= 0

func _ready():
	# Ensure the mob_scenes array is populated with the paths to your mob scenes
	if mob_scenes.is_empty():
		mob_scenes = [
			preload("res://clownfish.tscn"),
			preload("res://salmon.tscn"),
			preload("res://sunfish.tscn"),
			preload("res://shark.tscn"),
			preload("res://orc.tscn"),
			preload("res://whale.tscn")
		]
	# Start the timer
	var timer = Timer.new()
	timer.wait_time = 0 # Set the timer to 10 seconds
	timer.one_shot = false  # Make the timer repeat
	add_child(timer)  # Add the timer to the scene tree
	timer.start()  # Start the timer
	timer.timeout.connect(Callable(self, "_on_timer_timeout"))

func _on_timer_timeout():
	duplicate_child()

func duplicate_child():
	if mob_scenes.size() > 0:
		var mob_scene
		# Pick a random mob scene
		var random_index = randi() % mob_scenes.size()
		if curwave==1:
			if enemywave==7:
				enemywave=0
				curwave=2
			mob_scene = mob_scenes[wave1[enemywave]]
		if curwave==2:
			if enemywave==12:
				enemywave=0
				curwave=3
			mob_scene = mob_scenes[wave2[enemywave]]
		if curwave==3:
			if enemywave==18:
				enemywave=0
				curwave=4
			mob_scene = mob_scenes[wave3[enemywave]]
		# Instance the mob scene
		
		if curwave!=4:
			var new_child = mob_scene.instantiate()
			# Add the new child to the scene tree (this will automatically assign an owner)
			add_child(new_child)
			enemywave=enemywave+1
		
		# Set the position of the new child
			new_child.global_transform.origin = spawn_position
			# Set the rotation of the new child to the specified spawn rotation
			new_child.rotation_degrees = spawn_rotation
	else:
		push_error("No mob scenes assigned.")
