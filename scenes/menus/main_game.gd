extends Node2D

@onready var level_container = $LevelContainer

func _ready() -> void:
	# Load Level 1 automatically if the container is empty on start
	if level_container.get_child_count() == 0:
		load_level(preload("res://scenes/levels/Level1/level1.tscn"))

func load_level(next_level_packed: PackedScene) -> void:
	# 1. Remove the current level (if any)
	for child in level_container.get_children():
		child.queue_free()
	
	# 2. Wait for the deletion to finish (optional but safe)
	await get_tree().process_frame
	
	# 3. Add the new level
	var new_level = next_level_packed.instantiate()
	level_container.add_child(new_level)
	
	# 4. Optional: Pass persistent data (like XP) to the new player here
	# transfer_player_data(new_level)
