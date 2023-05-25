extends Camera3D

@export var SHIFT_MULTIPLIER = 3.5
@export var SPEED = 2
@export var SENSITIVITY = 0.002

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _input(event):
	# Receives mouse motion
	if event is InputEventMouseMotion and Input.is_action_pressed("move_camera"):
		var mouse_movement = event.relative * SENSITIVITY
		rotate_y(-mouse_movement.x)
		rotate_object_local(Vector3(1,0,0), -mouse_movement.y)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# get input directions
	var side_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var vertical_dir = Input.get_axis("move_up", "move_down")
	# create a 3d vector out of the inputs
	var direction = Vector3(side_dir.x, -vertical_dir, side_dir.y)
	
	# check if speedup button is pressed
	var speedup = 1.0
	if Input.is_action_pressed("move_speedup"):
		speedup = SHIFT_MULTIPLIER
	
	# compute velocity vec3
	var velocity = direction * SPEED * speedup * delta
	
	# translate the camera by the velocity
	translate(velocity)
