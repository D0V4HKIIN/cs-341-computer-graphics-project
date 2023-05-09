extends RigidBody3D

@export var float_force := 55
@export var water_drag := 0.05
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


var time = 0.0;
var submerged = false;

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
	var uv_x = wrapf(position.x / 10.0, 0, 1)
	var uv_y = wrapf(position.y / 10.0, 0, 1)
	var pixel_pos = Vector2(uv_x * noise.get_width(), uv_y * noise.get_height())

	position += Vector2.ONE * (noise.get_pixelv(pixel_pos).r * 2.0 - 1.0);
	
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
	
	# some nice debug code
	#var water_height = get_water_height(Vector2(global_position.x, global_position.z) / 2  + Vector2.ONE * time * 0.05 + boat_position_in_water)
	#global_position.y = water_height;
	
	# buoyancy approximation
	submerged = false
	for floater in floaters:
		var floater_tex_position = Vector2(floater.global_position.x, floater.global_position.z) / 2  + Vector2.ONE * time * 0.05 + boat_position_in_water;
		var depth = get_water_height(floater_tex_position) - floater.global_position.y 
		if depth > 0:
			submerged = true
			apply_force(Vector3.UP * float_force * gravity * sqrt(depth), floater.global_position - global_position)
			
func _integrate_forces(state: PhysicsDirectBodyState3D):
	if submerged:
		state.linear_velocity *=  1 - water_drag
		state.angular_velocity *= 1 - water_angular_drag 
