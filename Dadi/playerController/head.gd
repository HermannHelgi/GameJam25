extends Node3D

var holding: bool = false;
var held_object: Node3D = null
var held_original_parent: Node = null
var held_original_transform: Transform3D
var held_was_frozen: bool = false
var sensetivity = 0.2
const GRAB_ACTION := "grab"
const GRAB_LAYER := 2

@onready var raycast:RayCast3D = $RayCast3D
@onready var hold_position:Node3D = $holdposition

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		get_parent().rotate_y(deg_to_rad(-event.relative.x * sensetivity))
		rotate_x(deg_to_rad(-event.relative.y * sensetivity))
		rotation.x * clamp(rotation.x, deg_to_rad(-90), deg_to_rad(90) )
		#Grab - drop item action
		if event.is_action_pressed(GRAB_ACTION):
			if holding:
				drop_object()
			else:
				try_grab_object()

func try_grab_object() -> void:
	#Make sure raycast is hitting something
	if not raycast.is_colliding():
		return
	var collider := raycast.get_collider()
	if collider == null:
		return
	if not (collider is Node3D):
		return
	
	if collider is CollisionObject3D:
		var co := collider as CollisionObject3D
		if (co.collision_layer & GRAB_LAYER) == 0:
			return
	var body := collider as Node3D
	
	#save original parent + transform to restore on drop
	held_object = body
	held_original_parent = body.get_parent()
	held_original_transform = body.global_transform
	
	#if its rigidbody3d maybe freeze it?
	if body is RigidBody3D:
		var rb := body as RigidBody3D
		held_was_frozen = rb.freeze
		rb.freeze = true
	#reparent to hold position
	held_original_parent.remove_child(body)
	hold_position.add_child(body)
	
	#make it sit exacttly 
	body.transform = Transform3D.IDENTITY
	holding = true
	
func drop_object() -> void:
	if held_object == null:
		return
	var body := held_object
	
	#Remove the hold_posiiton
	hold_position.remove_child(body)
	held_original_parent.add_child(body)
	
	#put the object at the hold point 
	body.global_transform = hold_position.global_transform
	
	if body is RigidBody3D:
		var rb := body as RigidBody3D
		rb.freeze = held_was_frozen
	
	holding = false
	held_object = null
	held_original_parent = null
		
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
