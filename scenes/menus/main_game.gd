extends Node2D

@onready var level_container = $LevelContainer
# Reference the node you just created
@onready var video_player = $VideoLayer/VideoPlayer 

# Drag your Intro Video (.ogv) here in the Inspector
@export var intro_video: VideoStream 

var saved_stats: Dictionary = {}

func _ready() -> void:
	# Load Level 1 automatically if the container is empty on start
	if level_container.get_child_count() == 0:
		# If we have an intro video, play it first, then load Level 1
		if intro_video:
			play_video_transition(intro_video, preload("res://scenes/levels/Level1/level1.tscn"))
		else:
			load_level(preload("res://scenes/levels/Level1/level1.tscn"))

# Modified function to accept an optional video
func load_level(next_level_packed: PackedScene, transition_video: VideoStream = null) -> void:
	if transition_video:
		play_video_transition(transition_video, next_level_packed)
	else:
		_perform_level_swap(next_level_packed)

# Helper to handle the video logic
func play_video_transition(stream: VideoStream, next_level: PackedScene):
	get_tree().paused = true # Pause game logic during video
	
	video_player.stream = stream
	video_player.visible = true
	video_player.play()
	
	# Wait for the video to finish
	await video_player.finished
	
	video_player.stop()
	video_player.visible = false
	get_tree().paused = false
	
	_perform_level_swap(next_level)

# The actual level changing logic (moved from your original load_level)
func _perform_level_swap(next_level_packed: PackedScene):
	# A. SAVE DATA from the current level (if it exists)
	if level_container.get_child_count() > 0:
		var current_level = level_container.get_child(0)
		var player = current_level.get_node_or_null("Player")
		
		# If we found a player, save their stats
		if player and player.has_method("get_stats"):
			saved_stats = player.get_stats()
			print("Stats saved: ", saved_stats)
			
		current_level.queue_free()
	
	# Wait for deletion
	await get_tree().process_frame
	
	# B. LOAD NEW LEVEL
	var new_level = next_level_packed.instantiate()
	level_container.add_child(new_level)
	
	# C. RESTORE DATA to the new player
	var new_player = new_level.get_node_or_null("Player")
	if new_player and not saved_stats.is_empty():
		new_player.set_stats(saved_stats)
		print("Stats restored!")
