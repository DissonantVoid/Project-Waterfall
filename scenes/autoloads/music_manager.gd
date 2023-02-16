extends Node

#TODO music
#var main_music = load("res://<main_music_file>")
#var menu_music = load("res://<menu_music_file>")

func _ready():
	pass

#func play_music(music : String):
#	if music == "main":
#		$Music.stream = main_music
#		$Music.play()
#	elif music == "menu":
#		$Music.stream = menu_music
#		$Music.play()

func play_sound(sound : String):
	if sound == "collide":
		$CollideSound.play()
	elif sound == "falling":
		$FallingSound.play()
	elif sound == "score":
		$ScoreSound.play()
	elif sound == "splash":
		$SplashSound.play()
