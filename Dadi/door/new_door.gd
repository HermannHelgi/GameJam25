extends Node3D
class_name Door

@export var isOpen:bool = false

@onready var animator:AnimationPlayer = $AnimationPlayer


func open_door() -> void:
	animator.play("open_door")
	
func close_door() -> void:
	animator.play_backwards("open_door")
	
		
