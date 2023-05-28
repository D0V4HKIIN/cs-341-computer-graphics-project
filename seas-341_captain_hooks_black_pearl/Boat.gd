extends RigidBody3D

@export var float_force := 55
@export var water_drag := 0.05
@export var water_angular_drag := 0.05

@export var SPEED = 0.1
@export var ROTATION_SPEED = 0.02

@export var splash_threshhold_speed = 1.0

@onready var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var floaters = $floaters.get_children()
@onready var floater_depth : Array = Array()

@onready var ocean = $"../Ocean"

# Called when the node enters the scene tree for the first time.
func _ready():
	floater_depth.resize(floaters.size())

var submerged = false;
var boat_position_in_water = Vector2(0.0, 0.0);

func _physics_process(_delta):
	if Input.is_action_just_pressed("boat_reset"):
		rotation = Vector3(PI, rotation.y, rotation.z);
	
	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("boat_forward", "boat_back", "boat_left", "boat_right").normalized()
 
	# rotate and set speed accordingly
	rotate_y(-input_dir.y * ROTATION_SPEED)
	
	var displaced = Vector2(cos(-rotation.y), sin(-rotation.y)) * input_dir.x * SPEED
	boat_position_in_water += displaced
	# move the water shader
	for water in get_tree().get_nodes_in_group("Water"):
		water.get_active_material(0).set("shader_parameter/water_displacement", boat_position_in_water);
		water.get_active_material(0).set("shader_parameter/boat_rotation", rotation.y);
	
	# some nice debug code
	#var water_height = get_water_height(Vector2(global_position.x, global_position.z) / 2  + Vector2.ONE * time * 0.05 + boat_position_in_water)
	#global_position.y = water_height;
	
	# buoyancy approximation
	submerged = false
	for index in range(floaters.size()):
		var floater = floaters[index]
		var depth = ocean.get_water_height(floater.global_position) - floater.global_position.y 
		if depth > 0:
			submerged = true
			apply_force(Vector3.UP * float_force * gravity * sqrt(depth), floater.global_position - global_position)
			
			if(depth - floater_depth[index] > 0.01 && linear_velocity.y > splash_threshhold_speed):
				print(depth - floater_depth[index])
				floater.emitting = true
		
		floater_depth[index] = depth

func _integrate_forces(state: PhysicsDirectBodyState3D):
	if submerged:
		state.linear_velocity *=  1 - water_drag
		state.angular_velocity *= 1 - water_angular_drag 
