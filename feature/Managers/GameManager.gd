extends Node3D

@export var level = 1;
@export var StartingTimer = 30.0;
@export var BetweenTimer = 15.0;

@export var YuleLad: PackedScene
@export var YuleObjectiveAmount = 3;
@export var YuleSpawnLocation : Node;

var ItemSpawnLocations : Array[Node]
var PathLocations : Array[Node]
var rng = RandomNumberGenerator.new()

var timer = 0.0;

@export var YuleObjectives : Array[YuleObjectiveResource];
var SelectedYuleObjectives : Array[YuleObjectiveResource]
var EnumToObjectDict = {}
var AllYuleLads : Array[Node];

func _ready() -> void:
	PathLocations = get_tree().get_nodes_in_group("PathNode")
	ItemSpawnLocations = get_tree().get_nodes_in_group("SpawnNode")
	_generateObjects()
	timer = StartingTimer;

func _process(delta: float) -> void:
	if (timer >= 0):
		timer -= delta
		if (timer <= 0 && AllYuleLads.size() != level):
			var yuleSpawn = PathLocations[rng.randi_range(0, PathLocations.size() - 1)];
			var newYuleLad = YuleLad.instantiate()
			newYuleLad.global_position = yuleSpawn.global_position
			YuleSpawnLocation.add_child(newYuleLad)
			AllYuleLads.append(newYuleLad)
			timer = BetweenTimer;
			var obj = SelectedYuleObjectives.pop_at(rng.randi_range(0, SelectedYuleObjectives.size() - 1))
			newYuleLad.ObjectiveType = obj.Type

func _generateObjects() -> void:
	var count = 0
	while (count != level):
		var potentialObjective = YuleObjectives[rng.randi_range(0, YuleObjectives.size() - 1)]
		if (SelectedYuleObjectives.find(potentialObjective) == -1):
			SelectedYuleObjectives.append(potentialObjective)
			count += 1
			
			for j in range(YuleObjectiveAmount):
				var newItem = potentialObjective.Item.instantiate()
				
				var spawn = ItemSpawnLocations[rng.randi_range(0, ItemSpawnLocations.size() - 1)];
				if (spawn is spawn_location):
					while (spawn.HasSpawnedItem == true):
						spawn = ItemSpawnLocations[rng.randi_range(0, ItemSpawnLocations.size() - 1)]
						
					spawn.HasSpawnedItem = true;
					spawn.add_child(newItem)
					newItem.global_position = spawn.global_position
					if (EnumToObjectDict.has(potentialObjective.Type)):
						EnumToObjectDict[potentialObjective.Type].append(newItem);
					else:
						EnumToObjectDict[potentialObjective.Type] = [newItem];

func get_script_owner(node: Node) -> PhysicsObject:
	while node:
		if node is PhysicsObject:
			return node
		node = node.get_parent()
	return null
