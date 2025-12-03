extends Node3D
class_name Cat

@export var animation:AnimationPlayer
@export var player : Node3D
@export var catPosition:Vector3

var recentlyPetted : bool = false
var recentlyPettedTimer : float = 0.0
var playSoundTimer : float = 0.0
@export var audioPlayer : AudioStreamPlayer3D
@export var purrSounds : Array[AudioStreamWAV]

var recently_petted: bool = false
var recently_petted_timer: float = 0.0
var meow_timer: float = 0.0

var current_animation: String = ""

func _ready() -> void:
	current_animation = "Sit"
	if animation:
		animation.play("Sit")

func check_player_distance() -> float:
	var distance = catPosition.distance_to(player.global_position)
	return distance
	

func changeAnimation() -> void:
	var currentAnimation = animation.current_animation
	if (currentAnimation == "Sit") : 
		animation.play("Lay")
	elif (currentAnimation == "Lay") :
		animation.play("Sit") 
	

func play_random_purr() -> void:
	if purrSounds.is_empty():
		return
	if audioPlayer and not audioPlayer.playing:
		var idx := randi_range(0, purrSounds.size() - 1)
		audioPlayer.stream = purrSounds[idx]
		audioPlayer.play()
	
func pet() -> void:
	if(recentlyPetted):
		return
	else:
		play_random_purr()
		recentlyPetted = true
	
func _process(delta: float) -> void:
	if(recentlyPetted):
		playSoundTimer = 0.0
		recentlyPettedTimer += delta
		if (recentlyPettedTimer > 3):
			recentlyPetted = false
			playSoundTimer = recentlyPettedTimer
	elif(playSoundTimer < 10.0):
		playSoundTimer += delta
		print(playSoundTimer)
	elif(playSoundTimer > 10.0):
		play_random_purr()
	var playerDistance = check_player_distance()
	if(playerDistance > 5.0 ) and playSoundTimer > 10:
		changeAnimation()
		
	
	
#func 
