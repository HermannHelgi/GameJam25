extends Area3D

@export var door : Node3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#body_entered.connect(_on_body_entered)
	#body_exited.connect(_on_body_exited)
	pass
	
func _on_area_3d_body_entered(body):
	print(" ENTER " ,body , body.name)
	if not door.isOpen and body is CollisionShape3D:
		door.open_door()

func _on_area_3d_body_exited(body):
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
