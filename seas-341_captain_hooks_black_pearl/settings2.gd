extends Control

@onready var ocean = $"../Ocean"
@onready var noise_material = load("res://water_noise_based.gdshader");
@onready var tessendorf_material = load("res://fft_shader.gdshader");

@onready var birds = $"../birds"

@onready var noise_button = $MarginContainer/VBoxContainer/noise_button;
@onready var tessendorf_button = $MarginContainer/VBoxContainer/tessendorf_button;

func change_wave_height(value):
	for water in get_tree().get_nodes_in_group("Water"):
		water.get_active_material(0).set("shader_parameter/height_scale", value);
	ocean.update_variables();

func change_wave_speed(value):
	print(value)
	for water in get_tree().get_nodes_in_group("Water"):
		water.get_active_material(0).set("shader_parameter/wave_speed", value);
	ocean.update_variables();

func change_birds(value):
	birds.multimesh.set_instance_count(value);
	print(value);

func _noise_pressed():
	print("noise")
	var water_meshes = ocean.getWater();
	
	for water in water_meshes:
		water.material_override = noise_material;

func _tessendorf_pressed():
	print("tessendorf")
	var water_meshes = ocean.getWater();
	
	for water in water_meshes:
		water.material_override = tessendorf_material;
	
