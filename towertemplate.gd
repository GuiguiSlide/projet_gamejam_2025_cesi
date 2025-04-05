extends Node3D

@onready var upper_part = $StaticBody3D/MeshInstance3D2
var enemy: Node3D = null

func _ready():
	# Find the first enemy in the scene
	var root = get_tree().get_current_scene()
	enemy = find_enemy(root)

	if enemy != null:
		print("Enemy found:", enemy.name)
	else:
		print("No enemy found!")

func _process(delta):
	if enemy == null:
		return

	var tower_pos = upper_part.global_transform.origin
	var enemy_pos = enemy.global_transform.origin

	# Ignore vertical difference so it only rotates on Y axis
	enemy_pos.y = tower_pos.y

	var direction = (enemy_pos - tower_pos).normalized()
	var target_yaw = atan2(direction.x, direction.z)

	var rotation = upper_part.rotation
	rotation.y = target_yaw
	upper_part.rotation = rotation

func find_enemy(node: Node) -> Node3D:
	# This version finds the first Node3D whose name starts with "Enemy"
	if node is Node3D and node.name.begins_with("Enemy"):
		return node
	for child in node.get_children():
		var result = find_enemy(child)
		if result != null:
			return result
	return null
