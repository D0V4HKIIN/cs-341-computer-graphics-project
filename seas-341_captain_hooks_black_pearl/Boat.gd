extends RigidBody3D

@export var float_force := 35
@export var water_drag := 0.3
@export var water_angular_drag := 0.05

@export var SPEED = 0.1
@export var ROTATION_SPEED = 0.02

@onready var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var floaters = $floaters.get_children()

@export var water_noise : NoiseTexture2D;
var noise : Image
var height_scale = 2;

# Called when the node enters the scene tree for the first time.
func _ready():
	var ocean = $"../Ocean"
	ocean.createOcean();
	await water_noise.changed
	noise = water_noise.get_image();
	print(water_noise);


var time = 0.0
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	time += delta
	
	var tree = get_tree();
	for water in tree.get_nodes_in_group("Water"):
		water.get_active_material(0).set("shader_parameter/cpu_time", time);
	
	var scale_param = tree.get_first_node_in_group("Water").get_active_material(0).get("shader_parameter/height_scale");

	if scale_param != null:
		height_scale = scale_param;

func wave(position):
	position += Vector2.ONE * (noise.get_pixel(position.x / 10.0, position.y / 10.0).r * 2.0 - 1.0);
	var wv = Vector2.ONE - Vector2(abs(sin(position.x)), abs(sin(position.y)));
	return pow(1.0 - pow(wv.x * wv.y, 0.65), 4.0);


func noise_height(position, time):
	var d = wave((position + Vector2.ONE * time) * 0.4) * 0.3;
	d += wave((position - Vector2.ONE * time) * 0.3) * 0.3;
	d += wave((position + Vector2.ONE * time) * 0.5) * 0.2;
	d += wave((position - Vector2.ONE * time) * 0.6) * 0.2;
	return d * height_scale;


func get_water_height(pos):
	return noise_height(pos, time);

var boat_position_in_water = Vector2(0.0, 0.0);

func _physics_process(delta):
	if(noise == null):
		print(noise)
		return
	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("boat_forward", "boat_back", "boat_left", "boat_right").normalized()
 
	# rotate and set speed accordingly
	rotate_y(-input_dir.y * ROTATION_SPEED)
	
	var displaced = Vector2(cos(-rotation.y), sin(-rotation.y)) * input_dir.x * SPEED
	boat_position_in_water += displaced
	# move the water shader
	for water in get_tree().get_nodes_in_group("Water"):
		water.get_active_material(0).set("shader_parameter/water_displacement", boat_position_in_water);
	
	# buoyancy approximation
	for floater in floaters:
		var depth = get_water_height(Vector2(floater.global_position.x, floater.global_position.z) + boat_position_in_water) - floater.global_position.y 
		if depth > 0:
			apply_force(Vector3.UP * float_force * gravity * sqrt(depth) * (1 - water_drag), floater.global_position - global_position)
			4
