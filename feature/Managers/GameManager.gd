extends Node3D

enum YuleObjects {POT, PAN, MILK, SPOON, CANDLE}


@export var level = 1;

@export var YuleLad: PackedScene
@export var YuleObjective: PackedScene

var ItemSpawnLocations : Array[Node]
var AllItems : Array[Node]
var PathLocations : Array[Node]

func _ready() -> void:
	PathLocations = get_tree().get_nodes_in_group("PathNode")
	ItemSpawnLocations = get_tree().get_nodes_in_group("SpawnNode")
	
	for spawn in ItemSpawnLocations:
		var newItem = YuleObjective.instantiate()
		spawn.add_child(newItem)
		newItem.global_position = spawn.global_position
		AllItems.append(newItem)
	
