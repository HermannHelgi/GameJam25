extends CharacterBody3D
@onready var audioManager : Node3D = $AudioManager
@onready var animator : Node = $Animator
@export var Speed = 4.0
@export var Reach = 2.0
@export var DistanceToObject = 1.0
@export var DistanceToSlowDown = 3.0

@export var MinIdleTime = 2.0
@export var MaxIdleTime = 6.0
@export var MinRandomIdleStops = 2
@export var MaxRandomIdleStops = 4

@export var DestroyTime = 3.0
@export var DistanceMinimumForNextNode = 3.0

var NavMesh : NavigationRegion3D
var ObjectiveType: GlobalEnums.YuleObjects;

var current_state : GlobalEnums.YuleState =	GlobalEnums.YuleState.IDLE
var target : Node = null
var rng = RandomNumberGenerator.new()
var timer = 0.0;
var idle_stop_count = 0
var GM

@onready var nav_agent = $NavigationAgent3D

@export var MaxStrikes = 3;
var current_strikes = 0;

func _ready() -> void:
	
	NavMesh = get_tree().get_nodes_in_group("NavMesh")[0];

	GM = get_tree().get_first_node_in_group("GameManager")
	if (GM == null):
		printerr("NO GAMEMANAGER FOUND IN SCENE.")
	
	# Debug animator
	print("Animator node: ", animator)
	if animator != null:
		print("Animator script: ", animator.get_script())
		print("Has play_state method: ", animator.has_method("play_state"))
		
	_fetchRandomLoc(false);
	timer = _randomTime()
	idle_stop_count = _randomStop();
	
func _process(delta: float) -> void:
	if (current_state == GlobalEnums.YuleState.IDLE):
		if animator != null:
			animator.play_state(current_state)
		else:
			printerr("Animator is null!")
		if (timer >= 0):
			timer -= delta
			if (timer < 0):
				print("WALK")
				audioManager.play_walking_sound()
				current_state = GlobalEnums.YuleState.WALKING
				idle_stop_count -= 1
				if (idle_stop_count == 0 && GM.EnumToObjectDict[ObjectiveType].size() != 0):
					_fetchRandomLoc(true)
				else:
					_fetchRandomLoc(false)
	
	elif (current_state == GlobalEnums.YuleState.WALKING):
		if animator != null:
			animator.play_state(current_state)
		if (nav_agent.is_navigation_finished()):
			var check = false
			# Am I trying to destroy this object?
			if (idle_stop_count == 0 && GM.EnumToObjectDict[ObjectiveType].size() != 0):
				# ...yes, is it being held or is it too far away?
				var targetDistance = global_position.distance_to(GM.get_script_owner(target).MeshLocation.global_position)
				if (GM.get_script_owner(target).IsHeld || targetDistance > Reach):
					# Yes, i'm going to go somewhere else then.
					idle_stop_count = _randomStop();
					check = true
					current_strikes += 1;
				else:
					# No, annihilate
					current_state = GlobalEnums.YuleState.DESTROYING
					timer = DestroyTime
					
					print("DESTROY")
					audioManager.play_destroying_sound()
			else:
				check = true
			
			if (current_strikes >= MaxStrikes):
				GM.AmountOfFreeYuleLads += 1
				self.queue_free()
			
			if (check):
				timer = _randomTime()
				current_state = GlobalEnums.YuleState.IDLE	
				print("IDLE")
				audioManager.play_laughing_sound()
	
	elif (current_state == GlobalEnums.YuleState.DESTROYING):
		if animator != null:
			animator.play_state(current_state)
		if (timer >= 0):
			timer -= delta
			if (GM.get_script_owner(target).IsHeld):
				idle_stop_count = _randomStop();
				audioManager.play_loosingItem_sound()
				current_state = GlobalEnums.YuleState.IDLE	
				
			if (timer < 0):
				print("WALK FROM DESTRUCTION")
				audioManager.play_laughing_sound()
				GM.EnumToObjectDict[ObjectiveType].pop_at(0);
				target.queue_free()
				idle_stop_count = _randomStop();
				current_state = GlobalEnums.YuleState.WALKING
				_fetchRandomLoc(false)
				GM.onStrikeGained()


func _physics_process(_delta: float) -> void:
	velocity = Vector3.ZERO
	
	if (current_state == GlobalEnums.YuleState.WALKING):
		var distance = 0 
		var last_nav_point = nav_agent.get_final_position()
		distance = global_position.distance_to(last_nav_point)
		
		var next_nav_point = nav_agent.get_next_path_position()
		look_at(Vector3(next_nav_point.x, global_position.y, next_nav_point.z))
		velocity = (next_nav_point - global_position).normalized() * Speed 
		if (distance <= DistanceToSlowDown):
			velocity *= distance / DistanceToSlowDown
		
		move_and_slide()

func _randomTime() -> float:
	return rng.randf_range(MinIdleTime, MaxIdleTime)

func _fetchRandomLoc(goForObjectiveItem: bool) -> void:
	var old_target = target
	if (goForObjectiveItem):
		while (old_target == target):
			target = GM.EnumToObjectDict[ObjectiveType][0];
			nav_agent.set_target_position(GM.get_script_owner(target).MeshLocation.global_position)
	else:
		while (old_target == target):
			target = GM.PathLocations[rng.randi_range(0, GM.PathLocations.size() - 1)];
			nav_agent.set_target_position(target.global_position)
			

func _randomStop() -> int:
	var thing = rng.randi_range(MinRandomIdleStops, MaxRandomIdleStops)
	return thing
