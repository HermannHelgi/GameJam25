extends Node3D

@export var NextScene : String
@export var StartScene : String
@export var isActive = true; # NEEDS TO BE TRUE TO START
@export var PlayerNode : Node

func _on_start_pressed() -> void:
	get_tree().change_scene_to_file(NextScene)
	
func _ready() -> void:
	_freeze_game()


func _on_quit() -> void:
	get_tree().quit()


func _freeze_game() -> void:
	get_tree().paused = isActive
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE if isActive else Input.MOUSE_MODE_CAPTURED)
	PlayerNode.CameraScriptNode.isActive = !isActive
	isActive = !isActive
