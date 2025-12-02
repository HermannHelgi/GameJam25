extends Node

@export var walkingSounds : Array[AudioStreamWAV]
@export var destroyingSounds : Array[AudioStreamWAV]
@export var laughingSounds : Array[AudioStreamWAV]
@export var loosingItemSound : Array[AudioStreamWAV]
@onready var audioEmitter : AudioStreamPlayer3D = $AudioStreamPlayer3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func play_walking_sound() -> void:
	audioEmitter.stream = walkingSounds[randi_range(0,walkingSounds.size() - 1)]
	audioEmitter.play()
	
func play_destroying_sound() -> void:
	audioEmitter.stream = destroyingSounds[randi_range(0, destroyingSounds.size() - 1)]
	audioEmitter.play()
	
func play_laughing_sound() -> void:
	audioEmitter.stream = laughingSounds[randi_range(0, laughingSounds.size() - 1)]
	audioEmitter.play()
	
func play_loosingItem_sound() -> void:
	audioEmitter.stream = loosingItemSound[randi_range(0, loosingItemSound.size() - 1)]
	audioEmitter.play()
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
