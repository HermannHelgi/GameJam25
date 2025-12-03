extends Node3D
class_name Santa

@onready var anim_player: AnimationPlayer = $AnimationPlayer

func _ready():
	_set_default_loops()

func _set_default_loops():
	var loops = {
		"Idle": true,
		"LookAround": false,
		"Walk": true,
		"Grab": false,
		"Stomp": false,
		"sHUCKS": false,
	}

	for anim in loops.keys():
		if anim_player.has_animation(anim):
			anim_player.get_animation(anim).loop = loops[anim]

func play_anim(anim_name: String):
	if not anim_player.has_animation(anim_name):
		push_warning("Animation not found: %s" % anim_name)
		return

	anim_player.play(anim_name)
