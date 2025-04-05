extends Node3D

@onready var upper_part = $StaticBody3D/MeshInstance3D2
var player: CharacterBody3D = null

func _ready():
	# Look for the first CharacterBody3D node in the current scene
	var root = get_tree().get_current_scene()
	player = find_player(root)

func _process(delta):
	if player == null:
		return

	var tower_position = upper_part.global_transform.origin
	var player_position = player.global_transform.origin

	# Flatten Y to only rotate horizontally
	player_position.y = tower_position.y

	var direction = (player_position - tower_position).normalized()
	var target_rotation = atan2(direction.x, direction.z)

	var current_rotation = upper_part.rotation
	current_rotation.y = target_rotation
	upper_part.rotation = current_rotation

func find_player(node: Node) -> CharacterBody3D:
	if node is CharacterBody3D:
		return node
	for child in node.get_children():
		var result = find_player(child)
		if result != null:
			return result
	return null
