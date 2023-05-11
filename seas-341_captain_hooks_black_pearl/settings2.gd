extends Control

@onready var ocean = $"../Ocean"

func _on_h_slider_value_changed(value):
	for water in get_tree().get_nodes_in_group("Water"):
		water.get_active_material(0).set("shader_parameter/height_scale", value);
	ocean.update_variables();


func _on_check_box_toggled(button_pressed):
	print(button_pressed)
