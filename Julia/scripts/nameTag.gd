extends Node3D
class_name NameTag

func _ready():
	# wait until next frame
	call_deferred("_update_label")

func _update_label():
	var yule_lad = get_parent()
	
	var sub_viewport = get_child(0)
	
	if sub_viewport is SubViewport:
		var label = sub_viewport.get_child(0)
	
		if label is Label:
			label.text = yule_lad.yule_lad_name
