extends CanvasLayer

signal upgrade_selected(power_id)

@onready var card_1 = $CenterContainer/BackgroundImage/HBoxContainer/card
@onready var card_2 = $CenterContainer/BackgroundImage/HBoxContainer/card2
@onready var hbox = $CenterContainer/BackgroundImage/HBoxContainer

# Configuração Central: ID -> Nome da Animação no Card
var powerup_data = {
	1: "gun_card_anim",
	2: "speed_card_anim"
}

# IDs que existem no jogo
var all_powerups = [1, 2]

# Variáveis para saber qual ID cada carta está segurando agora
var card_1_id = -1
var card_2_id = -1

func _ready() -> void:
	visible = false
	# Conecta os sinais de clique (mantido do seu código)
	card_1.pressed.connect(_on_card_1_selected)
	card_2.pressed.connect(_on_card_2_selected)

# AGORA RECEBE A LISTA DO QUE O PLAYER JÁ TEM
func show_cards(owned_powerups: Array):
	visible = true
	get_tree().paused = true
	
	# 1. Filtra a lista: Disponíveis = Todos - O que eu já tenho
	var available_options = []
	for id in all_powerups:
		if not id in owned_powerups:
			available_options.append(id)
	
	# Embaralha para ser aleatório (opcional, bom para roguelikes)
	available_options.shuffle()
	
	# 2. Configura a Carta 1
	if available_options.size() > 0:
		card_1.visible = true
		card_1_id = available_options.pop_front() # Pega o primeiro e remove da lista
		card_1.set_animation(powerup_data[card_1_id])
	else:
		card_1.visible = false # Se não tem nada, esconde
		
	# 3. Configura a Carta 2
	if available_options.size() > 0:
		card_2.visible = true
		card_2_id = available_options.pop_front()
		card_2.set_animation(powerup_data[card_2_id])
	else:
		card_2.visible = false # Se só sobrou 1 ou nenhum, esconde a segunda carta

# As funções de clique agora usam o ID dinâmico salvo na variável
func _on_card_1_selected():
	finish_selection(card_1_id)

func _on_card_2_selected():
	finish_selection(card_2_id)

func finish_selection(id: int):
	if id != -1: # Segurança para não enviar ID inválido
		emit_signal("upgrade_selected", id)
		queue_free()
		get_tree().paused = false
