# Arquivo: res://scripts/music_controller.gd (anexado ao nó MusicController)
extends Node

@onready var music_player = $MusicPlayer

const MUSIC_PATH = "res://assets/sounds/"

# Dicionário de caminhos (Defina aqui os nomes dos arquivos de música)
const TRACKS = {
	"menu": "menu.mp3",
	"level1": "level1.mp3",     
	"level2": "level2.mp3",
	"level3": "level3.mp3",
	"level4": "level4.mp3",
	"level5": "level5.mp3",        
}

# Variável para armazenar a música tocando atualmente
var current_track_name = ""

# Função que será chamada por cada cena (Level 1, Level 2, etc.)
func play_track(track_name: String):
	# 1. Checa se a música já está tocando
	if track_name == current_track_name:
		return # Já está tocando, não faz nada
	
	# 2. Verifica se o nome da música existe no dicionário
	if not TRACKS.has(track_name):
		print("Erro: Música '" + track_name + "' não encontrada no dicionário de TRACKS.")
		return

	# 3. Para a música atual (se houver) e carrega a nova
	var music_file_path = MUSIC_PATH + TRACKS[track_name]
	var new_stream = load(music_file_path) # Carrega o recurso de áudio
	
	if new_stream:
		music_player.stream = new_stream
		
		# Certifique-se de que a opção Loop está marcada no arquivo de áudio original!
		music_player.play()
		current_track_name = track_name
	else:
		print("Erro: Não foi possível carregar o arquivo: " + music_file_path)
