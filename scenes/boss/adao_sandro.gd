extends CharacterBody2D

# --- CONFIGURATION ---
@export var bullet_scene: PackedScene
@export var max_health: int = 10
@export var speed: float = 50.0

# --- END GAME SETTINGS ---
@export var ending_video: VideoStream
@export var credits_scene: PackedScene

# --- VARIABLES ---
var current_health: int
var shoot_timer: float = 0.0
var rot_index: float = 0.0

# "Fast" pattern: Shoots every 0.1 seconds
var shoot_interval: float = 0.1 

func _ready() -> void:
	current_health = max_health
	add_to_group("enemies") # Ensures player bullets can hit me

func _process(delta: float) -> void:
	# 1. Simple Movement (Optional: Floating effect)
	position.y += sin(Time.get_ticks_msec() / 500.0) * 0.5
	
	# 2. Shooting Logic (Spiral Pattern)
	shoot_timer -= delta
	if shoot_timer <= 0:
		shoot_timer = shoot_interval
		shoot_spiral()

func shoot_spiral() -> void:
	if not bullet_scene: return
	
	# 1. Create bullet instance
	var b = bullet_scene.instantiate()
	
	# 2. Add to scene FIRST (so it knows where it is in the world)
	get_parent().add_child(b)
	
	# 3. Set Global Position (Teleport exactly to Boss)
	b.global_position = global_position
	
	# 4. Apply Rotation
	rot_index += 15
	b.rotation = deg_to_rad(rot_index)

func take_damage(amount: int = 1) -> void:
	current_health -= amount
	modulate = Color(1, 0, 0) # Flash Red
	await get_tree().create_timer(0.1).timeout
	modulate = Color(1, 1, 1)
	
	if current_health <= 0:
		die()

func die() -> void:
	# Call MainGame to play video -> Load Credits
	var main_game = get_tree().current_scene
	if main_game.has_method("load_level") and credits_scene:
		main_game.load_level(credits_scene, ending_video)
	else:
		# Fallback if something is missing
		print("Boss Dead! (Check MainGame/Credits assignment)")
		queue_free()
