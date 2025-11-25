extends CanvasLayer

@onready var xp_mask: Control = $XPContainer/XP_Mask
@onready var xp_bar_sprite: TextureRect = $XPContainer/XP_Mask/XP_Bar_Sprite

# Guarde o tamanho máximo da máscara (largura total da barra em pixels)
# Você pode pegar isso no _ready ou definir manualmente se souber o valor
var max_bar_width: float

func _ready():
	# Pega a largura que você desenhou no editor como sendo o "100%"
	max_bar_width = xp_mask.size.x 

func update_xp(current_xp: int, max_xp_for_level: int):
	# 1. Calcula a porcentagem (0.0 a 1.0)
	var percent = float(current_xp) / float(max_xp_for_level)
	
	# 2. Aplica ao tamanho da máscara
	var new_width = max_bar_width * percent
	
	# Opcional: Animação suave (Tween)
	var tween = get_tree().create_tween()
	tween.tween_property(xp_mask, "size:x", new_width, 0.3).set_trans(Tween.TRANS_SINE)
