extends Node3D

@onready var body = $StaticBody3D
var speed = 2.0 # units per second

# Define the instruction list
var instructions = [
	{ "type": "move", "distance": 4 },
	{ "type": "turn", "angle": -90 },
	{ "type": "move", "distance": 10 },
	{ "type": "turn", "angle": 90 },
	{ "type": "move", "distance": 6 },
]

var current_instruction = 0
var distance_moved = 0.0

func _physics_process(delta):
	if current_instruction >= instructions.size():
		return # All instructions done

	var instr = instructions[current_instruction]

	if instr.type == "move":
		var move_distance = speed * delta
		var remaining = instr.distance - distance_moved
		var actual_move = min(move_distance, remaining)

		# Move forward in local Z direction
		translate(Vector3.FORWARD * actual_move)
		distance_moved += actual_move

		if distance_moved >= instr.distance:
			current_instruction += 1
			distance_moved = 0.0

	elif instr.type == "turn":
		# Turn in place (instant for now)
		rotate_y(deg_to_rad(instr.angle))
		current_instruction += 1
