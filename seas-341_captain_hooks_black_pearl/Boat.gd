extends RigidBody3D

@export var float_force := 0.35
@export var water_drag := 0.05
@export var water_angular_drag := 0.05

@export var SPEED = 0.1
@export var ROTATION_SPEED = 0.02

@onready var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var floaters = $floaters.get_children()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

var time = 0.0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += delta
	for water in get_tree().get_nodes_in_group("Water"):
		water.get_active_material(0).set("shader_parameter/cpu_time", time);
	
func get_water_height(pos):
	return (cos(pos.x / 2) + cos(pos.y / 2))/ 2 + 1.0;

var boat_position_in_water = Vector2(0.0, 0.0);

func _physics_process(delta):
		# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("boat_forward", "boat_back", "boat_left", "boat_right").normalized()
 
	# rotate and set speed accordingly
	rotate_y(-input_dir.y * ROTATION_SPEED)
	#var rotation = -global_transform.basis.get_euler().y;
	var displaced = Vector2(cos(-rotation.y), sin(-rotation.y)) * input_dir.x * SPEED
	boat_position_in_water += displaced
	# move the water shader
	for water in get_tree().get_nodes_in_group("Water"):
		water.get_active_material(0).set("shader_parameter/water_displacement", boat_position_in_water);
	
	# buoyancy approximation
	for floater in floaters:
		var depth = get_water_height(floater.global_position + Vector3(boat_position_in_water.x, 0, boat_position_in_water.y)) - floater.global_position.y 
		if depth > 0:
			apply_force(Vector3.UP * float_force * gravity * depth * (1 - water_drag), floater.global_position - global_position)
