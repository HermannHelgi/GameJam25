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
		var distance = global_position.distance_to(target.global_position)
		if (distance <= DistanceToObject):
			if (idle_stop_count == 0 && GM.EnumToObjectDict[ObjectiveType].size() != 0):
				current_state = GlobalEnums.YuleState.DESTROYING
				timer = DestroyTime
				print("DESTROY")
			else:	
				timer = _randomTime()
				current_state = GlobalEnums.YuleState.IDLE	
				print("IDLE")
	
	elif (current_state == GlobalEnums.YuleState.DESTROYING):
		if (timer >= 0):
			timer -= delta
			if (timer < 0):
				print("WALK FROM DESTRUCTION")
				GM.EnumToObjectDict[ObjectiveType].pop_at(0);
				target.queue_free()
				idle_stop_count = _randomStop();
				current_state = GlobalEnums.YuleState.WALKING
				_fetchRandomLoc(false)

func _physics_process(delta: float) -> void:
	velocity = Vector3.ZERO
	
	if (current_state == GlobalEnums.YuleState.WALKING):
		var distance = global_position.distance_to(target.global_position)
		nav_agent.set_target_position(target.global_position)
		var next_nav_point = nav_agent.get_next_path_position()
		look_at(Vector3(next_nav_point.x, global_position.y, next_nav_point.z))
		velocity = (next_nav_point - global_position).normalized() * Speed * delta 
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
	else:
		while (old_target == target):
			target = GM.PathLocations[rng.randi_range(0, GM.PathLocations.size() - 1)];

func _randomStop() -> int:
	var thing = rng.randi_range(MinRandomIdleStops, MaxRandomIdleStops)
	return thing
