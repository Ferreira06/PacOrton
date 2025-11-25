# Arquivo: MainMenu.gd (anexado ao nó raiz MainMenu)
extends Control

func _ready():
	# 1. Toca a música do menu. O Autoload MusicController vai parar qualquer
	#    música anterior e iniciar "menu".
	get_node("/root/MusicController").play_track("menu")
	
	# Você pode também garantir que o jogo não está pausado, se for o caso:
	get_tree().paused = false

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
#	pass
