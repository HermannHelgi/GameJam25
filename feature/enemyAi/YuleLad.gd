extends CharacterBody3D

enum YuleState {IDLE, WALKING, DESTROYING}

@export var Speed = 4.0
@export var Reach = 2.0
@export var DistanceToObject = 1.0
@export var DistanceToSlowDown = 3.0
@export var walkLocations : Array[Node] # TEMP
@export var objectiveLocations : Array[Node] # TEMP

@export var MinIdleTime = 2.0
@export var MaxIdleTime = 6.0
@export var MinRandomIdleStops = 2
@export var MaxRandomIdleStops = 4

@export var DestroyTime = 3.0

@export var NavMesh : NavigationRegion3D

var current_state : YuleState =	YuleState.IDLE
var target : Node = null
var rng = RandomNumberGenerator.new()
var timer = 0.0;
var idle_stop_count = 0

@onready var nav_agent = $NavigationAgent3D

func _ready() -> void:
	if (NavMesh == null):
		printerr("NAV MESH IS MISSING ON YULE LAD")
	
	_fetchRandomLoc(false);
	timer = _randomTime()
	idle_stop_count = _randomStop();
	
func _process(delta: float) -> void:
	if (current_state == YuleState.IDLE):
		if (timer >= 0):
			timer -= delta
			if (timer < 0):
				print("WALK")
				
				current_state = YuleState.WALKING
				idle_stop_count -= 1
				if (idle_stop_count == 0 && objectiveLocations.size() != 0):
					_fetchRandomLoc(true)
				else:
					_fetchRandomLoc(false)
				
	elif (current_state == YuleState.WALKING):
		var distance = global_position.distance_to(target.global_position)
		if (distance <= DistanceToObject):
			if (idle_stop_count == 0 && objectiveLocations.size() != 0):
				current_state = YuleState.DESTROYING
				timer = DestroyTime
				print("DESTROY")
			else:	
				timer = _randomTime()
				current_state = YuleState.IDLE	
				print("IDLE")
	
	elif (current_state == YuleState.DESTROYING):
		if (timer >= 0):
			timer -= delta
			if (timer < 0):
				print("WALK FROM DESTRUCTION")
				objectiveLocations.remove_at(objectiveLocations.find(target))
				target.queue_free()
				idle_stop_count = _randomStop();
				current_state = YuleState.WALKING
				_fetchRandomLoc(false)

func _physics_process(delta: float) -> void:
	velocity = Vector3.ZERO
	
	if (current_state == YuleState.WALKING):
		var distance = global_position.distance_to(target.global_position)
		nav_agent.set_target_position(target.global_position)
		var next_nav_point = nav_agent.get_next_path_position()
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
			target = objectiveLocations[rng.randi_range(0, objectiveLocations.size() - 1)];
	else:
		while (old_target == target):
			target = walkLocations[rng.randi_range(0, walkLocations.size() - 1)];

func _randomStop() -> int:
	var thing = rng.randi_range(MinRandomIdleStops, MaxRandomIdleStops)
	print(thing)
	return thing
