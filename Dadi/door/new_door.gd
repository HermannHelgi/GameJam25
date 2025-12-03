extends Node3D
class_name Door

@export var isOpen:bool = false

@onready var animator:AnimationPlayer = $AnimationPlayer
#@onready var openArea : Area3D = $Area3D

func _ready() -> void:
	pass

func open_door() -> void:
	animator.play("open_door")
	isOpen = true
	
func close_door() -> void:
	animator.play_backwards("open_door")
	isOpen = false
	


func _on_body_entered(body: Node3D) -> void:
	print("ENTER:", body, body.name)
	if body.is_in_group("YuleLads") and not isOpen:
		open_door()
	#pass # Replace with function body.


func _on_body_exited(body: Node3D) -> void:
	print("ENTER:", body, body.name)
	if body.is_in_group("YuleLads") and isOpen:
		close_door()
