extends Control

# --- CONFIGURATION ---
# Drag your files here in the Inspector
@export var video_dialogo1: VideoStream
@export var screenshot_texture: Texture2D
@export var video_fase1: VideoStream
@export var main_game_scene: PackedScene = preload("res://scenes/menus/main_game.tscn")

# Duration to show the screenshot (in seconds)
@export var image_duration: float = 3.0

# --- NODES ---
@onready var menu_ui = $CenterContainer # The container holding your buttons
@onready var intro_video_player = $IntroVideoPlayer
@onready var intro_image = $IntroImage
@onready var music_controller = get_node("/root/MusicController")

# --- STATE MACHINE ---
enum State { MENU, VIDEO_1, SCREENSHOT, VIDEO_2 }
var current_state = State.MENU

func _ready():
	# Ensure the game is running and music is playing
	get_tree().paused = false
	music_controller.play_track("menu")
	
	# Connect the Play button (adjust the path if your button is different)
	var play_btn = find_child("Play", true, false)
	if play_btn:
		play_btn.pressed.connect(_on_play_pressed)
	
	# Connect video finished signal via code (or do it in Editor)
	if not intro_video_player.finished.is_connected(_on_video_finished):
		intro_video_player.finished.connect(_on_video_finished)

# --- INPUT HANDLING (SPACE TO SKIP) ---
func _input(event):
	# If Space or Enter is pressed, skip to the next stage
	if event.is_action_pressed("ui_accept") and current_state != State.MENU:
		_advance_sequence()

# --- SEQUENCE LOGIC ---
func _on_play_pressed():
	# 1. Start the Sequence
	music_controller.stop() # Stop menu music
	menu_ui.visible = false # Hide buttons
	
	# Start Video 1 ("Dialogo 1")
	_start_video_1()

func _start_video_1():
	current_state = State.VIDEO_1
	intro_video_player.stream = video_dialogo1
	intro_video_player.visible = true
	intro_video_player.play()

func _start_screenshot():
	current_state = State.SCREENSHOT
	intro_video_player.stop()
	intro_video_player.visible = false
	
	# Show Image
	intro_image.texture = screenshot_texture
	intro_image.visible = true
	
	# Create a timer to automatically go to next step after X seconds
	get_tree().create_timer(image_duration).timeout.connect(_on_screenshot_timeout)

func _start_video_2():
	current_state = State.VIDEO_2
	intro_image.visible = false
	
	# Start Video 2 ("Fase 1")
	intro_video_player.stream = video_fase1
	intro_video_player.visible = true
	intro_video_player.play()

func _start_game():
	# Sequence finished, load the game
	get_tree().change_scene_to_packed(main_game_scene)

# --- TRANSITION HANDLERS ---

func _advance_sequence():
	# This function decides what happens when skipping or finishing a stage
	match current_state:
		State.VIDEO_1:
			_start_screenshot()
		State.SCREENSHOT:
			# If we are viewing the image, force skip to Video 2
			_start_video_2()
		State.VIDEO_2:
			_start_game()

func _on_video_finished():
	# Called automatically when a video ends
	_advance_sequence()

func _on_screenshot_timeout():
	# Called automatically when the image timer runs out
	# Only advance if we are STILL in the screenshot state (user didn't skip already)
	if current_state == State.SCREENSHOT:
		_advance_sequence()
