extends Node3D

@onready var body = $StaticBody3D
@onready var anim = $StaticBody3D/blockbench_export/AnimationPlayer

var speed = 3
var has_reached_end = false
var health = 10  # Enemy health

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
	body.collision_layer = 3
	body.collision_mask = 1

func die():
	queue_free()

func take_damage(amount: int):
	health -= amount
	print("Enemy took", amount, "damage. Remaining:", health)
	if health <= 0:
		die()

func _physics_process(delta):
	if current_instruction >= instructions.size():
		if !has_reached_end:
			has_reached_end = true
			print("Enemy reached the end!")
			var player = get_tree().get_first_node_in_group("player")
			if player and player.has_method("take_damage"):
				player.take_damage(10)
			else:
				push_error("Player or take_damage() method not found!")
			queue_free()
		return

	anim.play("walk")
	var instr = instructions[current_instruction]
	match instr.type:
		"move":
			var move_dist = speed * delta
			var remaining = instr.distance - distance_moved
			var actual_move = min(move_dist, remaining)
			translate(Vector3.FORWARD * actual_move)
			distance_moved += actual_move
			if distance_moved >= instr.distance:
				current_instruction += 1
				distance_moved = 0.0
		"turn":
			rotate_y(deg_to_rad(instr.angle))
			current_instruction += 1
