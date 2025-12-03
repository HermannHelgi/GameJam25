extends Area3D

var enteringBody : Node3D = null
var exitedBody : Node3D = null
@onready var collider : CollisionShape3D = $Area3D/CollisionShape3D
@export var door : Node3D
var body : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)

func _on_body_entered(body):
	print(" ENTER " ,body , body.name)
	if !door.isOpen and body is YuleLad:
		door.open_door()

func _on_body_exited(body):
	
	if body is YuleLad:
		# Close only if there are no YuleLads left in the area
		var has_yulelad := false
		for b in get_overlapping_bodies():
			if b is YuleLad:
				has_yulelad = true
				break

		if not has_yulelad:
			door.close_door()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
