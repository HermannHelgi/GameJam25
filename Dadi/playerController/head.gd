extends Node3D

@export var spring_stiffness: float = 40.0
@export var spring_damping: float = 8.0

var holding: bool = false;
var held_object: Node3D = null
var held_original_parent: Node = null
var held_original_transform: Transform3D
var held_was_frozen: bool = false
var sensetivity = 0.004
const GRAB_ACTION := "grab"
const GRAB_LAYER := 2
var pitch: float = 0.0

@onready var raycast:RayCast3D = $RayCast3D
@onready var hold_position:Node3D = $holdposition

#@onready var head = $head
@onready var camera:Camera3D = $Camera3D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		#yaw left/right
		get_parent().rotate_y(-event.relative.x * sensetivity)
		
		#rotate_x(-event.relative.y * sensetivity)
		#pitch up/down
		pitch -= event.relative.y * sensetivity
		pitch = clamp(pitch, deg_to_rad(-60), deg_to_rad(60))
		rotation.x = pitch
		#rotation.x * clamp(rotation.x, deg_to_rad(-90), deg_to_rad(90))
		#rotation.x = clamp(rotation.x, deg_to_rad(-40), deg_to_rad(60))
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
	if not (collider is RigidBody3D):
		return
	
	if collider is CollisionShape3D:
		var co := collider as CollisionShape3D
		if (co.collision_layer & GRAB_LAYER) ==0:
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
		rb.freeze = false
		rb.gravity_scale = 0.0
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
	var rb:RigidBody3D = null
	if body is RigidBody3D:
		rb = body as RigidBody3D
		
	var world_transform: Transform3D = body.global_transform
	
	# Reparent it back to where it came from
	if body.get_parent() == hold_position and held_original_parent:
		hold_position.remove_child(body)
		held_original_parent.add_child(body)
		# Keep the world-space transform so it stays where it was dropped
		body.global_transform = world_transform

	# Restore physics
	if rb:
		rb.gravity_scale = 1.0
		rb.freeze = held_was_frozen
		# Optional: give it a little toss forward
		# var forward := -global_transform.basis.z
		# rb.apply_impulse(forward * 2.0)

	# Clear state
	held_object = null
	held_original_parent = null
	holding = false
		
func _physics_process(delta: float) -> void:
	if holding and held_object is RigidBody3D:
		_update_held_body_physics(delta)

func _update_held_body_physics(delta:float) -> void:
	var rb := held_object as RigidBody3D
	
	var target_pos: Vector3 = hold_position.global_transform.origin
	var current_pos: Vector3 = rb.global_transform.origin
	var to_target: Vector3 = target_pos - current_pos

	# Spring force
	var spring_force: Vector3 = to_target * spring_stiffness

	# Damping based on current velocity
	var damping_force: Vector3 = -rb.linear_velocity * spring_damping

	rb.apply_central_force(spring_force + damping_force)

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass
	#
