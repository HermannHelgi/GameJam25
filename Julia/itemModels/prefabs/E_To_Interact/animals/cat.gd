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
		current_animation = "Lay"

func play_random_purr() -> void:
	if purrSounds.is_empty():
		return
	if audioPlayer and not audioPlayer.playing:
		var idx := randi_range(0, purrSounds.size() - 1)
		audioPlayer.stream = purrSounds[idx]
		audioPlayer.play()

func play_random_meow() -> void:
	if meowSounds.is_empty():
		return
	if audioPlayer and not audioPlayer.playing:
		var idx := randi_range(0, meowSounds.size() - 1)
		audioPlayer.stream = meowSounds[idx]
		audioPlayer.play()
		
func pet() -> void:
	if audioPlayer:
		audioPlayer.stop()
	recently_petted = true
	recently_petted_timer = 0.0
	meow_timer = 0.0

	play_random_purr()

	
func _process(delta: float) -> void:
	# Handle pet / purr window
	if recently_petted:
		recently_petted_timer += delta
		meow_timer = 0.0  # disable meow timer while purring

		if recently_petted_timer >= purr_duration:
			recently_petted = false
			recently_petted_timer = 0.0
	else:
		# Handle random meow timing
		meow_timer += delta
		if meow_timer >= meow_interval:
			play_random_meow()
			meow_timer = 0.0

	# Update animation every frame based on distance + pet state
	changeAnimation()
	
	
#func 
