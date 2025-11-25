extends TextureButton

@onready var anim_sprite = $AnimatedSprite2D

# AGORA: A escala alvo do botão é 1 (tamanho real), não 5.
var target_scale: Vector2 = Vector2(1, 1) 

func set_animation(anim_name: String):
	if anim_sprite:
		anim_sprite.play(anim_name)

func _ready():
	# 1. Ajusta o PIVÔ para o centro do retângulo de 160x320
	pivot_offset = size / 2 
	
	# 2. Configura o SPRITE para crescer e ficar no meio
	if anim_sprite:
		# Escala a arte (32x64) em 5x para preencher o botão (160x320)
		anim_sprite.scale = Vector2(5, 5) 
		anim_sprite.position = size / 2
	
	# 3. Animação de "Pop-up" (o botão cresce de 0 a 1)
	scale = Vector2(0, 0)
	var tween = create_tween().set_trans(Tween.TRANS_ELASTIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "scale", target_scale, 0.5)
	
	# Conexões
	mouse_entered.connect(_on_hover)
	mouse_exited.connect(_on_exit)

func _on_hover():
	# Aumenta 10% (leve respiro)
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "scale", target_scale * 1.1, 0.1)

func _on_exit():
	var tween = create_tween().set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "scale", target_scale, 0.1)
