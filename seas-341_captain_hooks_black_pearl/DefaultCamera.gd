extends Camera3D

@export var SHIFT_MULTIPLIER = 2.5
@export var SPEED = 2
@export var SENSITIVITY = 0.2

var _total_pitch = 0.0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _input(event):
	# Receives mouse motion
	if event is InputEventMouseMotion and Input.is_action_pressed("move_camera"):
		var mouse_movement = event.relative * SENSITIVITY
		rotate_y(deg_to_rad(-mouse_movement.x))
		rotate_object_local(Vector3(1,0,0), deg_to_rad(-mouse_movement.y))

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var side_dir = Input.get_vector("move_left", "move_right", "move_forward", "move_back")
	var vertical_dir = Input.get_axis("move_up", "move_down")
	var direction = Vector3(side_dir.x, vertical_dir, side_dir.y)
	
	var speedup = 1.0
	if Input.is_action_pressed("move_speedup"):
		speedup = SHIFT_MULTIPLIER
		
	var velocity = direction * SPEED * speedup * delta
	
	translate(velocity)
