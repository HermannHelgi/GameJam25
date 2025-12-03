extends Node3D
class_name Cat

@export var animation:AnimationPlayer
@export var player : Node3D
@export var catPosition:Vector3

var recentlyPetted : bool = false
var recentlyPettedTimer : float = 0.0
var playSoundTimer : float = 0.0
var changePosition : bool = false
@export var audioPlayer : AudioStreamPlayer3D
@export var purrSounds : Array[AudioStreamWAV]


var current_animation: String = ""

func _ready() -> void:
	var starting_animation = randf_range(0, 1)
	if starting_animation == 0:		
		if animation:
			animation.play("Sit")
	else:
		if animation:
			animation.play("Lay")

func check_player_distance() -> float:
	var distance = catPosition.distance_to(player.global_position)
	return distance
	

func changeAnimation() -> void:
	changePosition = false
	var currentAnimation = animation.current_animation
	if (currentAnimation == "Sit") : 
		animation.play("Lay")
	elif (currentAnimation == "Lay") :
		animation.play("Sit") 
	

func play_random_purr() -> void:
	if purrSounds.is_empty():
		return
	if audioPlayer and not audioPlayer.playing:
		audioPlayer.stream = purrSounds[randi_range(0 , purrSounds.size() -1)]
		audioPlayer.play()
		playSoundTimer = 0.0
			
func pet() -> void:
	if(recentlyPetted):
		return
	else:
		recentlyPetted = true
		play_random_purr()
	
func _process(delta: float) -> void:
	if(recentlyPetted):
		playSoundTimer = 0.0
		recentlyPettedTimer += delta
		if (recentlyPettedTimer > 3):
			recentlyPetted = false
			changePosition = true
			playSoundTimer = recentlyPettedTimer
	elif(playSoundTimer < 15.0):
		playSoundTimer += delta
	elif(playSoundTimer > 15.0):
		play_random_purr()
	var playerDistance = check_player_distance()
	if(playerDistance > 10.0 ) and playSoundTimer > 15 and changePosition:
		changeAnimation()
		
	
	
#func 
