extends Node3D

@onready var upper_part = $StaticBody3D/blockbench_export/Node/all/gun
@onready var detection_area: Area3D = $DetectionArea
@onready var anime= $StaticBody3D/blockbench_export/AnimationPlayer

var damage: int = 5
var targets: Array = []
var current_target: Node3D = null
var damage_interval: float = 1.0  # Time interval for damage in seconds
var last_damage_time: float = 0.0

func _ready():
	if not detection_area:
		push_error("DetectionArea node is missing!")
		return

	# Set up collision layers/masks according to your project settings

func _process(_delta):
	# Clean up any invalid or destroyed targets
	targets = targets.filter(func(t): return is_instance_valid(t))
	
	position.y = 0
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
	
	# Apply damage every second
	var current_time = Time.get_ticks_msec() / 1000.0  # Convert to seconds
	if current_target and current_time - last_damage_time >= damage_interval:
		last_damage_time = current_time
		if current_target.has_method("take_damage"):
			current_target.take_damage(damage)

func _on_detection_area_area_shape_entered(_area_rid: RID, area: Area3D, _area_shape_index: int, _local_shape_index: int) -> void:
	print('dmg')
	var body = area.get_parent()
	if body.has_method("take_damage"):
		anime.play("shoot")
		body.take_damage(damage)
