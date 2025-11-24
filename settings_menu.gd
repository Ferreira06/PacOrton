extends Control

@onready var btn_back: Button = $Margin/SettingsVContainer/Buttons/Back
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	btn_back.pressed.connect(_on_back_pressed)

func _on_back_pressed() -> void:
	# If this is an overlay, just hide/free it. 
	# If it's a separate scene, change back to Main Menu.
	if get_parent().name == "MainMenu": 
		# If added as child
		queue_free()
	else:
		# If separate scene
		get_tree().change_scene_to_file("res://main_menu.tscn")
