extends Node3D

@onready var upper_part = $StaticBody3D/turretskin/Node/all/gun
@onready var detection_area: Area3D = $DetectionArea

var current_target: Node3D = null

func _ready():
	# Verify nodes exist
	if not detection_area:
		push_error("DetectionArea node is missing!")
		return
	
	# Configure collision
	detection_area.collision_layer = 0  # Towers don't need to be detected
	detection_area.collision_mask = 3   # Detect enemies (layer 3)
	
	# Connect signals to properly named functions
	if not detection_area.body_entered.is_connected(_on_detection_area_body_entered):
		detection_area.body_entered.connect(_on_detection_area_body_entered)
	if not detection_area.body_exited.is_connected(_on_detection_area_body_exited):
		detection_area.body_exited.connect(_on_detection_area_body_exited)

func _process(delta):
	if current_target and is_instance_valid(current_target):
		update_aim(current_target.global_position)

func update_aim(target_pos: Vector3):
	var tower_pos = upper_part.global_position
	target_pos.y = tower_pos.y  # Ignore vertical difference
	upper_part.look_at(target_pos, Vector3.UP)

# Correct signal handler functions
func _on_detection_area_body_entered(body: Node):
	if body.is_in_group("enemies"):
		print("Enemy detected: ", body.name)
		current_target = body

func _on_detection_area_body_exited(body: Node):
	if body == current_target:
		print("Enemy lost: ", body.name)
		current_target = null
