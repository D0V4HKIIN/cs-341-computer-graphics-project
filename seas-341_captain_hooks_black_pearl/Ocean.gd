# makes the script run in the editor
@tool

extends Node3D

# Get waterplane and preset grid spawn info
var waterTile = preload("res://Water.tscn"); 
var spawnPoint = preload("res://OceanGridSpawnInfo.tres");

# Random
var rng = RandomNumberGenerator.new();
var random_number_xi;

var material : Material;

func getWater():
	return get_tree().get_nodes_in_group("Water");

# creates a bunch of water tiles and sets the position, subdivision and scale
func createOcean():
	for i in spawnPoint.spawnPoints.size():
		# Get location, subdivision, and scale of each tile
		var spawnLocation = spawnPoint.spawnPoints[i];
		var tileSubdivision = spawnPoint.subdivision[i];
		var tileScale = spawnPoint.scale[i];
		
		# Instanciate tile
		var waterInstance = waterTile.instantiate();
		
		# set position, subdivision and scale
		waterInstance.position = Vector3(spawnLocation.x, 0, spawnLocation.y) * waterInstance.mesh.size.x
		#waterInstance.mesh.set_subdivide_width(tileSubdivision);
		#waterInstance.mesh.set_subdivide_depth(tileSubdivision);
		waterInstance.set_scale(Vector3(tileScale, 1.0, tileScale)); # Ignore Y value because planes are 2d
		
		waterInstance.add_to_group("Water"); # to get the water meshes in the ui
		
		# Add to the scene
		add_child(waterInstance);
		
	material = get_tree().get_first_node_in_group("Water").get_active_material(0);
	

# Water shader varialbes
var water_noise : NoiseTexture2D;
var water_noise2 : NoiseTexture2D;
var noise : Image
var noise2 : Image
var height_scale = 1;
var wave_speed = 1;
var noise_frequency = 1;

func update_variables():
	print("updating variables");
	var tree = get_tree();
	material = tree.get_first_node_in_group("Water").get_active_material(0);
	
	# noise_frequency
	noise_frequency = material.get("shader_parameter/noise_frequency");
	
	# height_scale
	height_scale = material.get("shader_parameter/height_scale");
	
	# wave speed
	wave_speed = material.get("shader_parameter/wave_speed");
	
	# noise texture
	water_noise = material.get("shader_parameter/noise");
	water_noise2 = material.get("shader_parameter/noise2");
	await water_noise.changed
	await water_noise2.changed
	noise = water_noise.get_image();
	noise2 = water_noise2.get_image();

# called when scene is instanciated
func _ready():
	seed(1);
	random_number_xi = rng.randfn();
	
	createOcean();
	
	update_variables();

var cpu_time = 0.0;
func _process(delta):
	# compute time so that it's the same in cpu and gpu
	cpu_time += delta
	
	# set cpu_time
	var tree = get_tree();
	for water in tree.get_nodes_in_group("Water"):
		water.get_active_material(0).set("shader_parameter/cpu_time", cpu_time);

func wave(time_pos, pos):
	var uv_x = wrapf(time_pos.x * noise_frequency, 0, 1)
	var uv_y = wrapf(time_pos.y * noise_frequency, 0, 1)
	var pixel_pos = Vector2(uv_x * noise.get_width(), uv_y * noise.get_height())

	time_pos += Vector2.ONE * (noise.get_pixelv(pixel_pos).r * 2.0 - 1.0);
	
	var uv_x_d = wrapf(pos.x * noise_frequency, 0, 1)
	var uv_y_d = wrapf(pos.y * noise_frequency, 0, 1)
	var pixel_pos_d = Vector2(uv_x_d * noise2.get_width(), uv_y_d * noise2.get_height())
	var height_delta = noise2.get_pixelv(pixel_pos_d * noise_frequency).r * 0.2;
	
	var wv = 1 - abs(sin((time_pos.x + time_pos.y) * 0.8));
	return pow(1.0 - pow(wv, 0.65), 4.0) + height_delta;


func noise_height(pos, time):
	var d = wave((pos + Vector2.ONE * time) * 0.4, pos) * 0.3;
	d += wave((pos + Vector2.ONE * time * 1.1) * 0.3, pos) * 0.3;
	d += wave((pos + Vector2.ONE * time * 0.9) * 0.5, pos) * 0.2;
	d += wave((pos + Vector2.ONE * time) * 0.6, pos) * 0.2;
	return d * height_scale;


func get_water_height(pos):
	var boat_position_in_water = material.get("shader_parameter/water_displacement");	
	var floater_tex_position = Vector2(pos.x, pos.z) / 2  + Vector2.ONE * cpu_time * wave_speed + boat_position_in_water;
	if(noise == null):
		return 0;
	return noise_height(floater_tex_position, cpu_time);
