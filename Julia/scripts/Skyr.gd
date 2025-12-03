extends Node3D
class_name Skyr

@export var open_mesh: NodePath
@export var closed_mesh: NodePath

@export var isOpen:bool = true

func _ready():
	$closed_mesh.visible = false

func close_barrel() -> void:
	isOpen = false
	get_node(closed_mesh).visible = true
	get_node(open_mesh).visible = false
	
func open_barrel() -> void:
	isOpen = true
	get_node(open_mesh).visible = true
	get_node(closed_mesh).visible = false
	
	
