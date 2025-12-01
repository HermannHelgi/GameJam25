extends Node3D
class_name Radio

@onready var audioEmitter:AudioStreamPlayer3D = $Sketchfab_model2/SonyRadio_obj_cleaner_materialmerger_gles/Object_2/RadioAudio
@export var songs : Array[AudioStreamWAV]

var currentSong :AudioStreamWAV = null

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func play_music() -> void:
	if currentSong == null:
		print("playing song 1 ")
		currentSong = songs[0]
	
			
	elif(currentSong == songs[0]):
		print("playing song 2 ")
		currentSong = songs[1]
	
			
	else:
		currentSong = null
	if currentSong == null:
		audioEmitter.stop()
	audioEmitter.stream = currentSong
	audioEmitter.play()
	
	
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
