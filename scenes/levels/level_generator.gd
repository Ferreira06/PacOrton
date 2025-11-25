extends Node2D

@export var walkable_layer: TileMapLayer # Drag your "Zona" TileMapLayer here
@export var collectible_scene: PackedScene # Drag your collectible.tscn here

@onready var player = $Player
@onready var hud = $HUD

func _ready() -> void:
	get_node("/root/MusicController").play_track("level1")
	
	if walkable_layer and collectible_scene:
		spawn_points()
	
	# Conecta os sinais
	player.health_changed.connect(hud.update_health)
	player.stats_changed.connect(hud.update_stats)
	player.powerup_unlocked.connect(hud.unlock_powerup_slot)
	player.powerup_switched.connect(hud.highlight_slot)
	
	# AGENDA a inicialização para o próximo frame seguro
	call_deferred("setup_initial_ui")

func setup_initial_ui():
	hud.update_health(player.current_health)
	
	# O ideal é pegar essa variável do player se ela existir, ou chutar o valor do nível 1.
	hud.update_stats(player.xp, 10, player.level)
	

func spawn_points():
	# 1. Get all positions that are ALREADY occupied by manual items (Stars)
	var occupied_positions: Array[Vector2] = []
	
	for child in get_children():
		# We check if the child has the 'item_type' property (meaning it's a collectible)
		if "item_type" in child:
			occupied_positions.append(child.position)

	# 2. Get all grid tiles
	var cells = walkable_layer.get_used_cells()
	
	for cell_coords in cells:
		var world_pos = walkable_layer.map_to_local(cell_coords)
		
		# 3. Check if this spot is taken
		var is_spot_taken = false
		for taken_pos in occupied_positions:
			# We use distance < 5.0 to allow small floating point errors
			if world_pos.distance_to(taken_pos) < 5.0:
				is_spot_taken = true
				break
		
		# If a Star is already here, skip this tile!
		if is_spot_taken:
			continue

		# 4. Create the point (only if spot is empty)
		var item = collectible_scene.instantiate()
		item.position = world_pos
		item.item_type = 0 # 0 = POINT
		
		add_child(item)
