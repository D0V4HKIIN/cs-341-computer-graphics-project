extends CharacterBody3D


@export var SPEED = 10.0
@export var ROTATION_SPEED = 0.03
@export var JUMP_VELOCITY = 4.5

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")


func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("boat_forward", "boat_back", "boat_left", "boat_right").normalized()
	if input_dir:
		rotate_y(-input_dir.y * ROTATION_SPEED)
		velocity.x = input_dir.x * SPEED * cos(-global_rotation.y)
		velocity.z = input_dir.x * SPEED * sin(-global_rotation.y)
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
