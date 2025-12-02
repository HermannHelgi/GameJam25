extends Node3D
class_name Cat

@export var animation:AnimationPlayer
@export var player : Node3D
@export var catPosition:Vector3

var recentlyPetted : bool = false
var recentlyPettedTimer : float = 0.0
var playSoundTimer : float = 0.0
@export var audioPlayer : AudioStreamPlayer3D
@export var meowSounds : Array[AudioStreamWAV]
@export var purrSounds : Array[AudioStreamWAV]

func check_player_distance() -> float:
	var distance = catPosition.distance_to(player.global_position)
	return distance
	
func changeAnimation() -> void:
	var currentAnimation = animation.current_animation
	if (currentAnimation == "Sit"):
		animation.play("Lay")
	else:
		animation.play("Sit")

func play_random_purr() -> void:
	if(!recentlyPetted) :
		audioPlayer.stream = purrSounds[randi_range(0, purrSounds.size() - 1)]
	
	
func play_random_meow() -> void:
	audioPlayer.stream = meowSounds[randi_range(0, meowSounds.size() - 1)]
	
func _process(delta: float) -> void:
	if(recentlyPetted):
		playSoundTimer = 0.0
		recentlyPettedTimer += delta
		if (recentlyPettedTimer > 55):
			recentlyPetted = false
	if(playSoundTimer > 55.0):
		playSoundTimer += delta
	else:
		play_random_meow()
#func 
