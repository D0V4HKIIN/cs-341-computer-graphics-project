extends Node

@onready var main_camera = $"Camera3D"
@onready var boat_camera = $"Boat/Camera3D"
@onready var bezier_camera = $"bezier_camera"
@onready var rotating_camera = $"rotating_camera"
@onready var doubleBeizer_camera = $"doubleBeizer_camera"
@onready var moving_target = $"doubleBeizer_camera/movingTarget"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Input.is_action_just_pressed("camera_1"):
		main_camera.make_current();
	if Input.is_action_just_pressed("camera_2"):
		boat_camera.make_current();
	if Input.is_action_just_pressed("camera_3"):
		bezier_camera.make_current();
		bezier_camera.restart();
	if Input.is_action_just_pressed("camera_4"):
		rotating_camera.make_current();
	if Input.is_action_just_pressed("camera_5"):
		doubleBeizer_camera.make_current();
		doubleBeizer_camera.restart();
		moving_target.restart();
