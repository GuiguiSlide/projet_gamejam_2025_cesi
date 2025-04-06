extends Node3D

@onready var upper_part = $StaticBody3D/turretskin/Node/all/gun
@onready var detection_area: Area3D = $DetectionArea

var target: Array =[]
var current_target: Node3D = null
var body 

func _ready():
	if not detection_area:
		push_error("DetectionArea node is missing!")
		return

	# Configure the detection area for the tower
	detection_area.collision_layer = 3  # Set to the same layer as enemies
	detection_area.collision_mask = 1   # Set to detect enemies' layer
	#detection_area.body_entered.connect(_on_detection_area_body_entered)
	#detection_area.body_exited.connect(_on_detection_area_body_exited)
	detection_area.monitoring = true



func _process(_delta):
	
	upper_part.rotation.y += 1

func _on_detection_area_area_shape_entered(area_rid: RID, area: Area3D, area_shape_index: int, local_shape_index: int) -> void:
	target.append(area)
	body = area.get_parent()
	
func _on_detection_area_area_shape_exited(area_rid: RID, area: Area3D, area_shape_index: int, local_shape_index: int) -> void:
	target.erase(area)
	print(target)
