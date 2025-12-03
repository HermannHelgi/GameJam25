extends Node3D
class_name YuleLadAnimator

@onready var anim_player: AnimationPlayer = $AnimationPlayer

var current_state: GlobalEnums.YuleState = GlobalEnums.YuleState.IDLE


func play_state(state: GlobalEnums.YuleState) -> void:
	if state == current_state:
		return
	
	current_state = state
	
	match state:
		GlobalEnums.YuleState.IDLE:
			anim_player.play("Idle")
		GlobalEnums.YuleState.WALKING:
			anim_player.play("Walk")
		GlobalEnums.YuleState.DESTROYING:
			anim_player.play("Grab")
		GlobalEnums.YuleState.ANGRY:
			anim_player.play("Stomp")
		GlobalEnums.YuleState.LOOKING:
			anim_player.play("LookAround")
		GlobalEnums.YuleState.SHUCKS:
			anim_player.play("sHUCKS")
