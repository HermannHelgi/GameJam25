extends Node3D

@export var SpawnableYuleLads = 0;
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

@export var PlayerNode : Node
@export var MainMenu : Node
@export var UI : Node
var isActive = true; # NEEDS TO BE TRUE TO START

var strikes = 0;
@export var maximumStrikes = 3;

@export var infoLabel : Array[Node]

@export var UITimer : Label
@export var TimerControlNode : Node
@export var ControlsNode : Node

@export var PopupNode : Node
@export var NameLabel : Label
@export var HideSubtitle : Label

var nameTimer = -1;
@export var DisplayTimeName = 0;

var AmountOfFreeYuleLads = 0;
@export var NextScene : PackedScene

var controlTimer = 90


func _ready() -> void:
	PathLocations = get_tree().get_nodes_in_group("PathNode")
	ItemSpawnLocations = get_tree().get_nodes_in_group("SpawnNode")
	_generateObjects()
	timer = StartingTimer;
	_freeze_game()
	# 	GM = get_tree().get_first_node_in_group("GameManager")

func _process(delta: float) -> void:
	if (isActive):
		if (timer >= 0):
			timer -= delta
			UITimer.text = str(int(timer)) + " seconds"
			if (timer <= 0 && AllYuleLads.size() != SpawnableYuleLads):
				var yuleSpawn = PathLocations[rng.randi_range(0, PathLocations.size() - 1)];
				var newYuleLad = YuleLad.instantiate()
				newYuleLad.global_position = yuleSpawn.global_position
				YuleSpawnLocation.add_child(newYuleLad)
				AllYuleLads.append(newYuleLad)
				timer = BetweenTimer;
				var obj = SelectedYuleObjectives.pop_at(rng.randi_range(0, SelectedYuleObjectives.size() - 1))
				newYuleLad.ObjectiveType = obj.Type
				displayNewYuleLad(obj.NameOfYuleLad, obj.NameOfItem, obj.NameOfItemEN);
				
				if (AllYuleLads.size() == SpawnableYuleLads):
					TimerControlNode.visible = false
		
		if (controlTimer >= 0):
			controlTimer -= delta
			if (controlTimer <= 0):
				ControlsNode.visible = false
		
		if (nameTimer >= 0):
			nameTimer -= delta
			if (nameTimer <= 0):
				PopupNode.visible = false

	if Input.is_action_just_pressed("Pause"):
		_freeze_game()
	
	if (SpawnableYuleLads == AmountOfFreeYuleLads):
		get_tree().change_scene_to_packed(NextScene)

func _generateObjects() -> void:
	var count = 0
	while (count != SpawnableYuleLads):
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


func onStrikeGained() -> void:
	strikes += 1
	if (strikes == maximumStrikes):
		get_tree().reload_current_scene()
	
	infoLabel[maximumStrikes - strikes].queue_free()


func _on_start_pressed() -> void:
	_freeze_game()


func _on_quit() -> void:
	get_tree().quit()


func _freeze_game() -> void:
	get_tree().paused = isActive
	MainMenu.set_visible(isActive)	
	UI.set_visible(!isActive)	
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE if isActive else Input.MOUSE_MODE_CAPTURED)
	PlayerNode.CameraScriptNode.isActive = !isActive
	isActive = !isActive

func displayNewYuleLad(name: String, objectName : String, objectNameEN : String) -> void:
	NameLabel.text = name.to_upper()
	HideSubtitle.text = "is coming!\nHide all your " + objectName + " (" + objectNameEN + ")!"
	nameTimer = DisplayTimeName
	PopupNode.visible = true
