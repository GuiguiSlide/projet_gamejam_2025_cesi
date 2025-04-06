extends Node3D

@onready var upper_part = $StaticBody3D/blockbench_export/Node/all/gun
@onready var detection_area: Area3D = $DetectionArea
var damage: int = 5
var targets: Array = []
var current_target: Node3D = null

func _ready():
	if not detection_area:
		push_error("DetectionArea node is missing!")
		return

	# Set up collision layers/masks according to your project settings

func _process(delta):
	# Clean up any invalid or destroyed targets
	targets = targets.filter(func(t): return is_instance_valid(t))
	
	# Update current target to first valid enemy
	if not targets.is_empty():
		current_target = targets[0]
	else:
		current_target = null
	
	# Rotate towards target
	if current_target:
		var target_pos = current_target.global_transform.origin
		target_pos.y = upper_part.global_transform.origin.y  # Keep rotation horizontal
		upper_part.look_at(target_pos, Vector3.UP)
	else:
		# Optional: Add idle behavior here
		pass


func _on_detection_area_area_shape_entered(area_rid: RID, area: Area3D, area_shape_index: int, local_shape_index: int) -> void:
	var body = area.get_parent()
	if body.has_method("take_damage"):
		body.take_damage(damage)
