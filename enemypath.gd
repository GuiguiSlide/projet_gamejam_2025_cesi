extends Node3D

@onready var body = $StaticBody3D
var speed = 2.0
var health = 100.0
var instructions = [
	{"type": "move", "distance": 12},
	{"type": "turn", "angle": 90},
	{"type": "move", "distance": 5},
	{"type": "turn", "angle": 90},
	{"type": "move", "distance": 4},
	{"type": "turn", "angle": 90},
	{"type": "move", "distance": 13},
	{"type": "turn", "angle": -90},
	{"type": "move", "distance": 6},
	{"type": "turn", "angle": -90},
	{"type": "move", "distance": 4},
	{"type": "turn", "angle": -90},
	{"type": "move", "distance": 12},
	{"type": "turn", "angle": 90},
	{"type": "move", "distance": 4},
	{"type": "turn", "angle": -90},
	{"type": "move", "distance": 4},
	{"type": "turn", "angle": -90},
	{"type": "move", "distance": 10},
	{"type": "turn", "angle": -90},
	{"type": "move", "distance": 7},
	{"type": "turn", "angle": 90},
	{"type": "move", "distance": 4},
]

var current_instruction = 0
var distance_moved = 0.0

func _ready():
	add_to_group("enemies")
	# Set collision layers/masks (layer numbers depend on your project settings)
	body.collision_layer = 3  # Enemies' layer
	body.collision_mask = 1   # Set to detect tower's detection area

func take_damage(amount):
	health -= amount
	if health <= 0:
		die()

func die():
	queue_free()

func _physics_process(delta):
	if current_instruction >= instructions.size():
		return

	var instr = instructions[current_instruction]
	
	match instr.type:
		"move":
			var move_dist = speed * delta
			var remaining = instr.distance - distance_moved
			var actual_move = min(move_dist, remaining)
			# Move along the node's local forward axis
			translate(Vector3.FORWARD * actual_move)
			distance_moved += actual_move
			if distance_moved >= instr.distance:
				current_instruction += 1
				distance_moved = 0.0
		"turn":
			rotate_y(deg_to_rad(instr.angle))
			current_instruction += 1
