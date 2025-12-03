extends Node3D
class_name Skyr

@export var open_mesh: NodePath
@export var closed_mesh: NodePath

@export var isOpen: bool = true

@onready var _open_node: Node = get_node_or_null(open_mesh) if open_mesh and str(open_mesh) != "" else null
@onready var _closed_node: Node = get_node_or_null(closed_mesh) if closed_mesh and str(closed_mesh) != "" else null

func _ready():
	if _closed_node:
		_closed_node.visible = false
	else:
		printerr("Skyr: closed_mesh not set or node not found on ", self)

func close_barrel() -> void:
	isOpen = false
	if _closed_node:
		_closed_node.visible = true
	elif closed_mesh:
		var n = get_node_or_null(closed_mesh)
		if n:
			n.visible = true

	if _open_node:
		_open_node.visible = false
	elif open_mesh:
		var n2 = get_node_or_null(open_mesh)
		if n2:
			n2.visible = false

func open_barrel() -> void:
	isOpen = true
	if _open_node:
		_open_node.visible = true
	elif open_mesh:
		var n = get_node_or_null(open_mesh)
		if n:
			n.visible = true

	if _closed_node:
		_closed_node.visible = false
	elif closed_mesh:
		var n2 = get_node_or_null(closed_mesh)
		if n2:
			n2.visible = false
