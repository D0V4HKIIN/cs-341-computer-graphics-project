extends CharacterBody3D


#@export var SPEED = 10.0
var SPEED = $Panel/HBoxContainer2/HSlider.value
@export var ROTATION_SPEED = 0.03
@export var JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

func set_speed(value):
	SPEED = value

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("boat_forward", "boat_back", "boat_left", "boat_right").normalized()

	# rotate and set speed accordingly
	rotate_y(-input_dir.y * ROTATION_SPEED)
	velocity.x = input_dir.x * SPEED * cos(-global_rotation.y)
	velocity.z = input_dir.x * SPEED * sin(-global_rotation.y)

	move_and_slide()
