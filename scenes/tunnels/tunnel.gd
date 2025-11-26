extends Area2D

# Drag the OTHER tunnel in the inspector for this variable
@export var linked_tunnel: Area2D

# Drag the Next Level scene file (.tscn) here
@export var next_level_scene: PackedScene

# A flag to prevent the tunnel from triggering immediately after receiving the player
var is_on_cooldown: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	# If this tunnel is on cooldown (just received the player), do nothing.
	if is_on_cooldown:
		return

	if body.name == "Player":
		check_tunnel_logic(body)

func check_tunnel_logic(player: Node2D) -> void:
	var ghost_count = get_tree().get_nodes_in_group("ghosts").size()
	
	if ghost_count < 0:
		# --- Phase NOT complete: Teleport ---
		if linked_tunnel:
			# 1. Activate cooldown on the DESTINATION tunnel so it doesn't send us back
			if linked_tunnel.has_method("activate_cooldown"):
				linked_tunnel.activate_cooldown()
			
			# 2. Teleport the player
			teleport_player(player)
		else:
			print("Tunnel: No linked tunnel assigned!")
			
	else:
		# --- Phase Complete: Next Level ---
		call_deferred("change_level")

func teleport_player(player: Node2D) -> void:
	# Move player to the linked tunnel position
	var new_pos = linked_tunnel.global_position.snapped(Vector2(16, 16)) + Vector2(16, 16) / 2.0
	
	
	
	# Update grid movement target so the player doesn't "snap back"
	if "target_pos" in player:
		player.target_pos = new_pos
	
	print("Teleported to: ", linked_tunnel.name)
	player.position = new_pos

# This function is called by the OTHER tunnel before sending the player here
func activate_cooldown() -> void:
	is_on_cooldown = true
	# Wait 1 second (enough time for player to walk out of the area)
	await get_tree().create_timer(1.0).timeout
	is_on_cooldown = false

func change_level() -> void:
	if next_level_scene:
		# Get the MainGame node (assumes MainGame is the root of the scene tree)
		var main_game = get_tree().current_scene
		
		if main_game.has_method("load_level"):
			# Use the new manager system
			main_game.load_level(next_level_scene)
		else:
			# Fallback: standard scene switch (if testing level directly)
			get_tree().change_scene_to_packed(next_level_scene)
	else:
		print("Tunnel: No next level scene assigned!")
