extends CanvasLayer

@onready var xp_mask: Control = $XPContainer/XP_Mask
@onready var level_label: Label = $LevelLabel
@onready var xp_bar_sprite: TextureRect = $XPContainer/XP_Mask/XP_Bar_Sprite

@onready var heart_container: HBoxContainer = $HeartContainer

# Arraste os sprites para cá no Inspector do Editor
@export var heart_full: Texture2D
@export var heart_empty: Texture2D
# Guarde o tamanho máximo da máscara (largura total da barra em pixels)
# Você pode pegar isso no _ready ou definir manualmente se souber o valor
var max_bar_width: float

@onready var slot_1_bg: TextureRect = $PowerupContainer/Slot1
@onready var slot_1_icon: TextureRect = $PowerupContainer/Slot1/Icon
@onready var slot_2_bg: TextureRect = $PowerupContainer/Slot2
@onready var slot_2_icon: TextureRect = $PowerupContainer/Slot2/Icon

# Arraste as imagens que você enviou para cá no Inspector
@export var bg_active: Texture2D    # A imagem do fundo "aceso/selecionado"
@export var bg_inactive: Texture2D  # A imagem do fundo "apagado/comum"

func _ready():
	if xp_mask:
		max_bar_width = xp_mask.size.x
	reset_slots()

func update_health(current_hp: int):
	var hearts = heart_container.get_children()
	for i in range(hearts.size()):
		if i < current_hp:
			hearts[i].texture = heart_full
		else:
			hearts[i].texture = heart_empty

func update_stats(current_xp: int, max_xp_for_level: int, current_level: int):
	# 1. Atualiza a Barra (Lógica antiga)
	if max_xp_for_level > 0:
		var percent = float(current_xp) / float(max_xp_for_level)
		var new_width = max_bar_width * percent
		
		# Animação da barra
		var tween = get_tree().create_tween()
		tween.tween_property(xp_mask, "size:x", new_width, 0.3).set_trans(Tween.TRANS_SINE)
	
	# Mostra apenas o número, ou "LVL 1", como preferir
	level_label.text = str(current_level)
	
func reset_slots():
	slot_1_bg.texture = bg_inactive
	slot_2_bg.texture = bg_inactive
	slot_1_icon.visible = false
	slot_2_icon.visible = false

# Chama essa função quando o jogador ganhar um powerup
func unlock_powerup_slot(id: int):
	if id == 1:
		slot_1_icon.visible = true
		# Opcional: Já seleciona automaticamente ao ganhar
		highlight_slot(1)
	elif id == 2:
		slot_2_icon.visible = true
		highlight_slot(2)

# Chama essa função quando o jogador apertar 1 ou 2
func highlight_slot(id: int):
	# Reseta ambos para inativo
	slot_1_bg.texture = bg_inactive
	slot_2_bg.texture = bg_inactive
	
	# Ativa apenas o selecionado
	if id == 1:
		slot_1_bg.texture = bg_active
	elif id == 2:
		slot_2_bg.texture = bg_active
