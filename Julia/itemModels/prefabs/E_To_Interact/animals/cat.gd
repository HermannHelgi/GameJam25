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

@export var near_distance: float = 5.0      # How close the player needs to be for "Sit"
@export var meow_interval: float = 45.0     # Time between random meows (seconds)
@export var purr_duration: float = 5.0      # How long the cat stays in "recently petted" state

var recently_petted: bool = false
var recently_petted_timer: float = 0.0
var meow_timer: float = 0.0

var current_animation: String = ""

func _ready() -> void:
	randomize()
	current_animation = "Sit"
	if animation:
		animation.play("Sit")

func check_player_distance() -> float:
	var distance = catPosition.distance_to(player.global_position)
	return distance
	
func on_petted() -> void:
	audioPlayer.stop()
	play_random_purr()
	recentlyPetted = true
	recentlyPettedTimer = 0.0
	playSoundTimer = 0.0
	
func changeAnimation() -> void:
	var d := check_player_distance()

	# Player close → Sit / attention
	if d <= near_distance:
		if current_animation != "Sit":
			animation.play("Sit")
			current_animation = "Sit"
		return

	# Player far → Lay, but only when not in the "recently petted" state
	if not recently_petted and current_animation != "Lay":
		animation.play("Lay")
		currentAnimation = "Lay"
		recentlyChangedAnimation = true
	elif (playSoundTimer > 20 )and recentlyChangedAnimation:
		animation.play("Sit")
		recentlyChangedAnimation = false

func play_random_purr() -> void:
	if purrSounds.is_empty():
		return
	if audioPlayer and not audioPlayer.playing:
		var idx := randi_range(0, purrSounds.size() - 1)
		audioPlayer.stream = purrSounds[idx]
		audioPlayer.play()
	
	
	
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
