extends Node3D

var sensetivity = 0.2
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	
func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		get_parent().rotate_y(deg_to_rad(-event.relative.x * sensetivity))
		rotate_x(deg_to_rad(-event.relative.y * sensetivity))
		rotation.x * clamp(rotation.x, deg_to_rad(-90), deg_to_rad(90) )
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
