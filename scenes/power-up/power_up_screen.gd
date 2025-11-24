extends CanvasLayer

signal upgrade_selected(power_id)

@onready var card_1 = $CenterContainer/HBoxContainer/card
@onready var card_2 = $CenterContainer/HBoxContainer/card2

func _ready() -> void:
	visible = false
	
	# Conecta o clique das cartas
	card_1.pressed.connect(_on_card_1_selected)
	card_2.pressed.connect(_on_card_2_selected)

func show_cards():
	visible = true
	get_tree().paused = true
	
	# Define as animações visuais das cartas (seus AnimatedSprite2D)
	# Certifique-se de ter criado animações com esses nomes no SpriteFrames da carta
	card_1.set_animation("gun_card_anim") 
	card_2.set_animation("speed_card_anim")

func _on_card_1_selected():
	finish_selection(1)

func _on_card_2_selected():
	finish_selection(2)

func finish_selection(id: int):
	emit_signal("upgrade_selected", id)
	queue_free()
	get_tree().paused = false
