extends CharacterBody3D

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

func _ready() -> void:
	NavMesh = get_tree().get_nodes_in_group("NavMesh")[0];

	GM = get_tree().get_first_node_in_group("GameManager")
	if (GM == null):
		printerr("NO GAMEMANAGER FOUND IN SCENE.")
		
	_fetchRandomLoc(false);
	timer = _randomTime()
	idle_stop_count = _randomStop();
	
func _process(delta: float) -> void:
	if (current_state == GlobalEnums.YuleState.IDLE):
		if (timer >= 0):
			timer -= delta
			if (timer < 0):
				print("WALK")
				
				current_state = GlobalEnums.YuleState.WALKING
				idle_stop_count -= 1
				if (idle_stop_count == 0 && GM.EnumToObjectDict[ObjectiveType].size() != 0):
					_fetchRandomLoc(true)
				else:
					_fetchRandomLoc(false)
	
	elif (current_state == GlobalEnums.YuleState.WALKING):
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
				else:
					# No, annihilate
					current_state = GlobalEnums.YuleState.DESTROYING
					timer = DestroyTime
					print("DESTROY")
			else:
				check = true
			
			if (check):
				timer = _randomTime()
				current_state = GlobalEnums.YuleState.IDLE	
				print("IDLE")
	
	elif (current_state == GlobalEnums.YuleState.DESTROYING):
		if (timer >= 0):
			timer -= delta
			if (GM.get_script_owner(target).IsHeld):
				idle_stop_count = _randomStop();
				current_state = GlobalEnums.YuleState.IDLE	
			
			if (timer < 0):
				print("WALK FROM DESTRUCTION")
				GM.EnumToObjectDict[ObjectiveType].pop_at(0);
				target.queue_free()
				idle_stop_count = _randomStop();
				current_state = GlobalEnums.YuleState.WALKING
				_fetchRandomLoc(false)

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
