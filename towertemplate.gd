extends Node3D

@onready var upper_part = $StaticBody3D/turretskin/Node/all/gun
@onready var detection_area: Area3D = $DetectionArea

var current_target: Node3D = null

func _ready():
	if not detection_area:
		push_error("DetectionArea node is missing!")
		return

	# Configure the detection area for the tower
	detection_area.collision_layer = 3  # Set to the same layer as enemies
	detection_area.collision_mask = 1   # Set to detect enemies' layer
	detection_area.body_entered.connect(_on_detection_area_body_entered)
	detection_area.body_exited.connect(_on_detection_area_body_exited)
	detection_area.monitoring = true

func _process(_delta):
	if current_target and is_instance_valid(current_target):
		update_aim(current_target.global_position)

func update_aim(target_pos: Vector3):
	var tower_pos = upper_part.global_position
	target_pos.y = tower_pos.y  # Ignore vertical difference for aiming
	upper_part.look_at(target_pos, Vector3.UP)


func _on_detection_area_body_entered(body: Node3D):
	print("Enemy detected: ", body.name)
	if body.is_in_group("enemies"):
		print("Enemy detected: ", body.name)
		current_target = body

func _on_detection_area_body_exited(body: Node3D):
	print("Enemy detected: ", body.name)
	if body == current_target:
		print("Enemy lost: ", body.name)
		current_target = null
