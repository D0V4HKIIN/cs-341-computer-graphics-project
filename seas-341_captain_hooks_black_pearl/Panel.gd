extends Panel

onready var ocean = $"../Ocean"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	match
	 "SPEED": ocean.set_speed($Panel/HBoxContainer2/HSlider.value)
