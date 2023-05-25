@tool
extends MultiMeshInstance3D

@onready var box = $"../birds/Box"

var box_vertices: Vector3

var BOID_COUNT = 10
const BOID_SPEED_MIN = 3.0
const BOID_SPEED_MAX = 10.0
const NEIGHBOR_DISTANCE = 3.0
const AVOIDANCE_DISTANCE = 2.0
const ALIGNMENT_WEIGHT = 0.6
const COHESION_WEIGHT = 0.01
const SEPARATION_WEIGHT = 0.7
const BOUNDARY_DISTANCE = 7.0
const BOUNDARY_WEIGHT = 0.3
const ATTRACTION_WEIGHT = 0.1

var attractor_positions: PackedVector3Array
@export var attractor_count = 100

var boid_positions: PackedVector3Array
var boid_velocities: PackedVector3Array
var min_vertex = Vector3(INF, INF, INF)
var max_vertex = Vector3(-INF, -INF, -INF)

func setup():
	BOID_COUNT = multimesh.instance_count
	boid_positions.resize(BOID_COUNT)
	boid_velocities.resize(BOID_COUNT)
	attractor_positions.resize(attractor_count)
	
	var box_aabb = box.get_aabb()
	
	for i in range(8):
		var curr = box_aabb.get_endpoint(i)
		if min_vertex > curr:
			min_vertex = curr
		
		if max_vertex < curr:
			max_vertex = curr
			
	for i in range(attractor_count):
		attractor_positions[i] = Vector3(randf_range(min_vertex.x, max_vertex.x), randf_range(min_vertex.y, max_vertex.y), randf_range(min_vertex.z, max_vertex.z))
	
	for i in range(BOID_COUNT):
		boid_positions[i] = Vector3(randf_range(min_vertex.x, max_vertex.x), randf_range(min_vertex.y, max_vertex.y), randf_range(min_vertex.z, max_vertex.z))
		boid_velocities[i] = Vector3(randf_range(-1, 1), randf_range(-1, 1), randf_range(-1, 1)).normalized() * randf_range(BOID_SPEED_MIN, BOID_SPEED_MAX)
		multimesh.set_instance_transform(i, Transform3D(Basis(), boid_positions[i]))
		multimesh.set_instance_custom_data(i, Color(randf(), randf(), randf(), randf()))


# Called when the node enters the scene tree for the first time.
func _ready():
	setup()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	for i in range(multimesh.instance_count):
		var position = boid_positions[i]
		var velocity = boid_velocities[i]

		# Get the average velocity and position of neighboring boids
		var average_velocity = Vector3()
		var average_position = Vector3()
		var separation = Vector3()
		var neighbor_count = 0

		for j in range(multimesh.instance_count):
			if i != j:
				var neighbor_position = boid_positions[j]

				# Calculate distance to neighbor
				var distance = position.distance_to(neighbor_position)

				# Check if neighbor is within the neighbor distance
				if distance < NEIGHBOR_DISTANCE:
					average_velocity += boid_velocities[j]
					average_position += neighbor_position

				# Separation behavior
				if distance < AVOIDANCE_DISTANCE:
					separation += (neighbor_position - position).normalized() / distance

				neighbor_count += 1

		if neighbor_count > 0:
			average_velocity /= neighbor_count
			average_position /= neighbor_count
			separation /= neighbor_count

			var alignment = average_velocity.normalized()
			var cohesion = (average_position - position).normalized()

			var steer = alignment * ALIGNMENT_WEIGHT + cohesion * COHESION_WEIGHT - separation * SEPARATION_WEIGHT
			
			# Apply boundary avoidance behavior
			var boundary_force = calculate_boundary_force(position)
			steer += boundary_force * BOUNDARY_WEIGHT
			
			# Attraction towards attractor positions
			var attractor_force = calculate_attractor_force(position)
			steer += attractor_force * ATTRACTION_WEIGHT
			
			# Apply steering force to boid
			velocity = (velocity + steer).normalized() * randf_range(BOID_SPEED_MIN, BOID_SPEED_MAX)

			# Apply steering force to boid
			position += velocity * delta

			# Perform boundary checks
			position = clamp(position, min_vertex,  max_vertex)

			boid_positions[i] = position
			boid_velocities[i] = velocity
			var rotation = Transform3D().looking_at(-velocity, Vector3.UP)
			
			multimesh.set_instance_transform(i, Transform3D(rotation.basis, position))

func calculate_boundary_force(position):
	var boundary_force = Vector3.ZERO

	if position.x < min_vertex.x + BOUNDARY_DISTANCE:
		boundary_force.x = 1.0 - (position.x - min_vertex.x) / BOUNDARY_DISTANCE
	elif position.x > max_vertex.x - BOUNDARY_DISTANCE:
		boundary_force.x = -1.0 + (position.x - max_vertex.x) / BOUNDARY_DISTANCE

	if position.y < min_vertex.y + BOUNDARY_DISTANCE:
		boundary_force.y = 1.0 - (position.y - min_vertex.y) / BOUNDARY_DISTANCE
	elif position.y > max_vertex.y - BOUNDARY_DISTANCE:
		boundary_force.y = -1.0 + (position.y - max_vertex.y) / BOUNDARY_DISTANCE

	if position.z < min_vertex.z + BOUNDARY_DISTANCE:
		boundary_force.z = 1.0 - (position.z - min_vertex.z) / BOUNDARY_DISTANCE
	elif position.z > max_vertex.z - BOUNDARY_DISTANCE:
		boundary_force.z = -1.0 + (position.z - max_vertex.z) / BOUNDARY_DISTANCE

	return boundary_force

func calculate_attractor_force(position):
	var attractor_force = Vector3.ZERO

	for attractor_pos in attractor_positions:
		attractor_force += (attractor_pos - position).normalized()

	if attractor_positions.size() > 0:
		attractor_force /= attractor_positions.size()

	return attractor_force
