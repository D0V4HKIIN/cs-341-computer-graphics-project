extends Control

@onready var ocean = $"../Ocean"
@onready var noise_material = load("res://water_noise_based.gdshader");
@onready var tessendorf_material = load("res://fft_shader.gdshader");

@onready var birds = $"../birds"

func change_wave_height(value):
	for water in get_tree().get_nodes_in_group("Water"):
		water.get_active_material(0).set("shader_parameter/height_scale", value);
	ocean.update_variables();

func change_wave_speed(value):
	for water in get_tree().get_nodes_in_group("Water"):
		water.get_active_material(0).set("shader_parameter/wave_speed", value);
	ocean.update_variables();

func change_birds(value):
	birds.multimesh.set_instance_count(value);
	birds.setup()
