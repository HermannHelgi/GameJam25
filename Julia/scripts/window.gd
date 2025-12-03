extends Node3D
class_name WindowAn

@export var isOpen:bool = true
@onready var animator:AnimationPlayer = $AnimationPlayer

func close_window() -> void:
	animator.play("closeWindow")
	isOpen = false
	
func open_window() -> void:
	animator.play_backwards("closeWindow")
	isOpen = true
	
